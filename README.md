# kali-profiles
Kali Profiles is a boot script for Offensive Security's Kali Virtual Machine images that allow you to create and select client profiles at boot along with Clearnet or Whonix network profiles, all while encrypting files with [gocryptfs](https://nuetzlich.net/gocryptfs/).

## How it works

At boot it asks for your encryption password, then displays the menus which will replace your user directory with the profile before starting the network and logging in:
```
-------------------------------
[1] Client A
[2] Client B
[D] Default
[C] Create new profile
[S] Drop to shell
-------------------------------
Choose profile: 
```

And then ask you to select your network profile:
```
-------------------------------
[C] Clearnet
[W] Whonix
-------------------------------
Choose network: 
```
The VM will retain the selected user and network profile even through reboots until you change profiles (See usage below).


## To set up
1) Set up a Whonix Gateway from [Whonix](https://www.whonix.org/download/)
2) Set up a Kali VM from [Offensive Security](https://www.offensive-security.com/kali-linux-vm-vmware-virtualbox-image-download/)
3) In VirtualBox for the Kali VM, add a second network adapter using the `Internal Network` of `Whonix`
4) In VirtualBox for the Kali VM, add a shared folder named `Vault`. This can be on a cloud storage provider such as [Nextcloud](https://nextcloud.com/) as client files will be encrypted in the VM with gocryptfs.
4) Boot the Whonix Gateway
5) Boot the Kali VM
6) Set up the Kali VM's root profile in X Windows however you would like as a default profile
7) Install kali-profiles:
```
mount -t vboxsf Vault /media/Vault
cd /media/Vault
git clone https://github.com/Fmstrat/kali-profiles.git .
/media/Vault/plain/setup.sh
```

The first thing the script will ask is the user you would like to set up multiple profiles for. In most cases, this is `root`:
```
Enter the user you would like to sync (most commonly root): root
```

Next, it will create a `/media/Vault/cipher` directory and encrypt it with the selected password in gocryptfs:
```
Enter password for encryption: 
```
The Vault share could be included in cloud storage since it is encrypted. This is where profiles (copies of the user folder) will be stored.

After this, the script will:
- Set up an `/etc/rc.local` that forces profile selection at boot
- Add the `Vault` share to `/etc/fstab` so we can mount the `cipher` folder as `/mnt/Vault` after boot.
- Create a `/mnt/Vault/profiles` directory where profiles are stored
- Create a `/mnt/Vault/bin` directory in the path, so you can store encrypted scripts for use across all profiles
- Create a `/mnt/Vault/data` directory where any data can be stored encrypted and shared accross profiles
- Create a `/mnt/Vault/bashrc` that is encrypted and called by every profiles `~/.bashrc` to keep static aliases/etc.

After the script completes, reboot and you will be in the default profile with clearnet access.

If you wish to edit the network profiles, take a look at the following files:
```
/media/Vault/plain/setup/interfaces.clearnet
/media/Vault/plain/setup/resolv.conf.clearnet
/media/Vault/plain/setup/interfaces.whonix
/media/Vault/plain/setup/resolv.conf.whonix
```
- When the `clearnet` profile is enabled, `eth0` is used for clearnet access, and `eth1` is not used.
- When the `whonix` profile is enabled, `eth1` is used for TOR access via Whonix, and `eth0` is not used.


## Usage

See current profile:
```
curprofile
```

Sync existing profile back to Vault share, clear out existing profile in VM, disable the network, then reboot to change to new one:
```
changeprofile reboot
```

Sync existing profile back to Vault share, clear out existing profile in VM, disable the network, then power off:
```
changeprofile
```
