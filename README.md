Windigo's Bash Menagerie
===

Welcome to my collection of small, reusable bash/shell scripts. A modge-podge of
useful utilities, designed to scratch my particular itches. Your mileage may
vary, but you are more than welcome to try them out for yourself!

**Note:** Not all of these have been documented yet, but I'll add more as I get
to it.

`backup.sh`
---

A rsync wrapper that adds some sanity checks, defaults and shortcuts.

`block_ip.sh <IP address or host value>`
---

Uses the `route` command to block traffic from a particular host/IP address

`newest.sh|oldest.sh <directory>`
---

Find the newest or oldest file/directory in a directory, *sorted by filename*.
Filenames should be a standardized date format, like YYYY-MM-DD. These scripts
are used in my home-grown backup system to find a suitable `link-dest` value,
and to pick which daily differentials should be cleaned up.

`public_ip.sh`
---
Uses [opendns.com](https://opendns.com) to discover your public IP address. If
this script is symlinked & called as `public_ipv4`, it resolves your IPv4 
address - otherwise, it resolves your public IPv6 address.

`random_file_listing.sh|random_file.sh|random_subdirectory.sh [directory]`
---
`random_file_listing.sh` lists all of the files in a directory, recursively, and
randomly ordered. `random_file.sh` will return a single random file from a
directory, and `random_subdirectory.sh` finds and returns a random sub-directory
by recursively calling itself until it doesn't randomly find another
sub-directory.

`reboot_easy_or_hard_way.sh`
---
Attempt to reboot using the `shutdown` command, with a delay of five minutes.

If that process returns false, echo a bunch of special characters to
`/proc/sysrq-trigger` to try to get the system to reboot.

`sleepy-vlc.sh <file>`
---
Play a file with VLC, and kill the process after three hours. I believe I made
this for a friend who used to fall asleep watching DVDs, and would leave the
DVD menus playing all night.

`update_software.sh`
---
Attempt to update all of the different possible types of software repositories
on a machine. Currently supported:
* deb/apt
* flatpak
* snap

`vm.sh`
---
Start a QEMU VM, with a set of virtual hardware and configurations that I find
useful.

Symlink the script as `vm`, and it starts a full graphical VM with a
video output, mouse, audio, etc.

Symlink the script as `vm_console`, and it starts a VM without graphics or
audio hardware, and instead connects the current terminal to the VM serial
output.

Use `vm.sh|vm|vm_console -h` to get a very outdated usage display