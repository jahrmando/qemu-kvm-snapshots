#!/bin/bash
#
#########################################################################
#
#	QEMU/KVM - EXTERNAL SNAPSHOTS (OFFLINE)
# 	This script will help you make backups of your virtual machines in 
# 	offline mode using the 'virsh' tool
#
#	Writen by: Jesus Armando Uch Canul
#	Report bugs to: https://github.com/jahrmando/qemu-kvm-snapshots/issues
#	Version: v0.1		Released: 2013-09-02
#	Licenced under GPLv3
#
#########################################################################
#
#
DIR_BACKUP='/media/kvm_pool/backups/test'
# VMs for ignore . Example: ignore VMs with name VMtest1 and VMtest2
IGNREG='^(VMtest1|VMtest2)$' 
# Timeout on seconds. WARNING! You must be very sure how much time needed 
# your servers for shutdown
MAX_TIME_OUT=360
# Number of snapshot for keep
KEEP_SNAPSHOTS=3
# Choose mode shutdown for servers. Safe mode via 'shutdown' command or
# Force mode via 'destroy' command.
MODE_POWEROFF='shutdown'
#
DATE=$(date +%Y-%m-%d)
#
find_disks(){
	for pool in $(virsh pool-list |awk {'print $1'} |sed '1,2 d'); do
		for disk in $(virsh vol-list $pool |awk '{print $2}' |sed '1 d'); do
			if [[ -n $(virsh dumpxml $1 |grep $disk) ]]; then
				disks="$disks $disk"
			fi
		done
	done
	echo $disks
}

purge_backups(){
	echo "Remove old backups.."; let "KEEP_SNAPSHOTS++"
	for dir in $(ls -lr $DIR_BACKUP |sed '1 d' |tail -n +$KEEP_SNAPSHOTS \
		|awk '{print $9}'); do
		rm -rf "$DIR_BACKUP/$dir"
	done
}

reset_directory(){
	if [[ -d "$DIR_BACKUP/$DATE" ]]; then
		rm -rf "$DIR_BACKUP/$DATE"; mkdir "$DIR_BACKUP/$DATE"
	else 
		mkdir "$DIR_BACKUP/$DATE"
	fi
}

check_vms(){
	for vm in $1; do
		if [[ -z $(virsh list |awk 'NF>1{print $2}' |sed '1 d' \
			|grep $vm) ]]; then
			echo "Server $vm is not started.. Trying to start!"
			virsh start ${vm} > /dev/null 2>&1; sleep 5
		else echo "Server $vm it is OK!"; sleep 5
		fi
	done
}

if [[ `whoami` == 'root' ]]; then
		echo "Running backups! $(date '+%T %d/%m/%y')"
		list_vms=''; reset_directory

		for vm in $(virsh list |awk '(NF > 1){print $2}' |sed '1 d' \
			|egrep -v ${IGNREG}) ; do
			list_disks=$(find_disks $vm); echo "Backing up $vm server"
			if [[ -n $list_disks ]]; then
				list_vms="$list_vms $vm"
				GOBACKUP=true; CONT=0
				echo -n "Stoping $vm server"
				virsh ${MODE_POWEROFF} ${vm} > /dev/null 2>&1

				while [[ -n $(virsh list |sed '1 d' |grep $vm \
					|awk '{print $3}') ]]; do

					if [[ "$CONT" -gt "$MAX_TIME_OUT" ]]; then
						echo " Time out!"; GOBACKUP=false
						break
					fi
					let "CONT++"; echo -n "."; sleep 1
				done

				if $GOBACKUP ; then
					echo ''
					for disk in $list_disks; do
						if [[ -n $(virsh dumpxml $vm |grep $disk) ]]; then
							echo 'Calculating checksum.. '
							checksum=$(md5sum $disk | awk '{print $1}')
							echo -n "Making backup disk $disk.. "
							(cp "$disk" "$DIR_BACKUP/$DATE/"; echo "Done!")
							echo -n 'Checking integrity.. '
							nameDisk="$(echo $disk |sed 's/^\/.*\///g')"
							if [[ "$checksum" == $(md5sum $DIR_BACKUP/$DATE/$nameDisk \
								|awk '{print $1}') ]]; then
								echo 'Pass!'
							else 
								echo 'Fatal! [Remove backup]'
								rm "$DIR_BACKUP/$DATE/$nameDisk"
							fi
						fi
					done
					echo "Starting $vm server.. "
					virsh start ${vm} > /dev/null 2>&1; sleep 5
				fi
			else echo "Not found disk in pools for server $vm"
			fi
		done
		purge_backups; sleep 8
		check_vms "$list_vms"
		echo "Exit! $(date '+%T %d/%m/%y')"
else
	echo "I need ROOT privileges $USER!"
fi

exit 0
