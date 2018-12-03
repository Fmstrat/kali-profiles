#!/bin/bash

SF=Vault

set -e

apt-get update && apt-get install -y gocryptfs
echo ""

if [ -d "/media/${SF}/cipher" ]; then
	mkdir -p "/mnt/${SF}"
	gocryptfs /media/Vault/cipher /mnt/Vault
	SYNCPATH=$(cat /mnt/Vault/syncpath)
	SYNCPATH=$(echo $SYNCPATH)
	cp "/media/${SF}/plain/setup/rc.local" /etc/rc.local
	chmod +x /etc/rc.local
	echo "Vault /media/Vault vboxsf defaults 0 0" >> /etc/fstab
	cp -a /media/Vault/plain/setup/interfaces.disabled /etc/network/interfaces
	cp -a /media/Vault/plain/setup/resolv.conf.disabled /etc/resolv.conf
fi

echo "[Done]"
echo ""
echo "Now reboot!"
