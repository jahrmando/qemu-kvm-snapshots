QEMU/KVM EXTERNAL SNAPSHOTS (offline)
=====================================
This script will help you make backups of your virtual machines in offline mode using the `virsh` tool.

**_NOTES:_**

* Make sure the disks of virtual machines they're added at least one __pool__. Because the script searches for disks on __pools__.
* The script needs privilege to run `virsh`
* To automate the script you can use __crontab__ tool

Example Output 1:

```
$ sudo sh qemu-kvm-snapshots
Running backups! 12:37:37 02/09/13
Backing up CentOS-DjangoTest server
Stoping CentOS-DjangoTest server.......
Calculating checksum.. 
Making backup disk /home/jahrmando/VMs/CentOS-DjangoTest.img.. Done!
Checking integrity.. Pass!
Starting CentOS-DjangoTest server.. 
Backing up WindowsXP server
Stoping WindowsXP server..............
Calculating checksum.. 
Making backup disk /home/jahrmando/VMs/WindowsXP.img.. Done!
Checking integrity.. Pass!
Starting WindowsXP server.. 
Remove old backups..
Server CentOS-DjangoTest it is OK!
Server WindowsXP it is OK!
Exit! 12:42:34 02/09/13
```
Example Output 2:
```
$ sudo sh qemu-kvm-snapshots
Running backups! 13:37:37 02/09/13
Backing up Fedora19 server
Stoping Fedora19 server..................... Time out!
Backing up CentOS-DjangoTest server
Stoping CentOS-DjangoTest server......
Calculating checksum.. 
Making backup disk /home/jahrmando/VMs/CentOS-DjangoTest.img.. Done!
Checking integrity.. Pass!
Starting CentOS-DjangoTest server.. 
Backing up WindowsXP server
Not found disk in pools for server WindowsXP
Remove old backups..
Server Fedora19 it is OK!
Server CentOS-DjangoTest it is OK!
Exit! 13:42:34 02/09/13
```
Example Output 3:
```
$ sudo sh qemu-kvm-snapshots
Running backups! 14:37:37 02/09/13
Backing up CentOS-DjangoTest server
Stoping CentOS-DjangoTest server.........
Calculating checksum.. 
Making backup disk /home/jahrmando/VMs/CentOS-DjangoTest.img.. Done!
Checking integrity.. Pass!
Starting CentOS-DjangoTest server.. 
Backing up WindowsXP server
Stoping WindowsXP server........... Time out!
Remove old backups..
Server CentOS-DjangoTest it is OK!
Server WindowsXP is not started.. Trying to start!
Exit! 14:42:34 02/09/13
```

I'll be happy to receive your __feedback__ to improve the script. Greetings!
