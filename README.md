# kali-profiles
Kali Profiles is a boot script for Offensive Security's Kali Virtual Machine images that allow you to create and select client profiles at boot along with Clearnet or Whonix network profiles, all while encrypting files with [gocryptfs](https://nuetzlich.net/gocryptfs/).

**Under Development**

## To use
1) Set up a Whonix Gateway from [Whonix](https://www.whonix.org/download/)
2) Set up a Kali VM from [Offensive Security](https://www.offensive-security.com/kali-linux-vm-vmware-virtualbox-image-download/)
3) In VirtualBox for the Kali VM, add a second network adapter using the `Internal Network` of `Whonix`
4) In VirtualBox for the Kali VM, add a shared folder named `Vault`. This can be on a cloud storage provider such as `Nextcloud` as client files will be encrypted in the VM with gocryptfs.
4) Boot the Whonix Gateway
5) Boot the Kali VM
6) Set up the Kali VM's root profile in X Windows however you would like as a default profile
7) Install kali-profiles:
```
mount -t vboxfs Vault /media/Vault
cd /media/Vault
git clone https://github.com/Fmstrat/kali-profiles.git
/media/Vault/plain/bin/setup.sh
```
Follow the prompts, and then reboot!
