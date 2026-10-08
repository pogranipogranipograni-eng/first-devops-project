# Linux System Directories Overview

## Core System Directories

* **/var**: Stores data that keeps growing while the system runs, like logs and app caches.
* **/sys**: Shows information about your computer hardware and system settings.
* **/mnt**: A temporary spot used to plug in external drives or USBs.
* **/tmp**: A scratchpad for temporary files that apps create and often delete on reboot.
* **/usr**: Holds most of the programs and apps you use every day.
* **/dev**: Contains files that represent your hardware devices, like hard drives and keyboards.

---

## Terminal Output Analysis

### Disk Usage in `/var`
```bash
root@debian-test-devops-kurse:/# du -sh /var/*
400K    /var/backups
205M    /var/cache
161M    /var/lib
4.0K    /var/local
0       /var/lock
26M     /var/log
4.0K    /var/mail
4.0K    /var/opt
0       /var/run
4.0K    /var/spool
32K     /var/tmp

root@debian-test-devops-kurse:/# du -sh /var
391M    /var

root@debian-test-devops-kurse:/# find / -name .gitconfig
/root/.gitconfig
