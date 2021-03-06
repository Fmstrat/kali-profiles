#!/bin/bash

SF=Vault

set -e

apt-get update && apt-get install -y gocryptfs
echo ""

while [ -z "$SYNCPATH" -o -z "$SYNCUSER" ]; do
	echo -n "Enter the user you would like to sync (most commonly root): "
	read SYNCUSER
	SYNCPATH=$(getent passwd $SYNCUSER |cut -d: -f6)
	if [ -z "$SYNCPATH" -o -z "$SYNCUSER" ]; then
		echo "User not found."
	fi
done

while [ -z "$PASSWORD" -o "$PASSWORD" != "$CONFIRM" ]; do
	echo -n "Enter password for encryption: "
	read -s PASSWORD
	echo ""
	echo -n "Confirm password: "
	read -s CONFIRM
	echo ""
	if [ -z "$PASSWORD" -o "$PASSWORD" != "$CONFIRM" ]; then
		echo "Passwords much match and cannot be empty."
	fi
done

mkdir -p "/media/${SF}/cipher"
mkdir -p "/mnt/${SF}"

gocryptfs -init "/media/${SF}/cipher" << EOF
${PASSWORD}
EOF
gocryptfs "/media/${SF}/cipher" "/mnt/${SF}" << EOF
${PASSWORD}
EOF

cp "/media/${SF}/plain/setup/rc.local" /etc/rc.local
chmod +x /etc/rc.local

echo "Vault /media/Vault vboxsf defaults 0 0" >> /etc/fstab

# Shutdown service is still under development
#cp /media/${SF}/plain/setup/syncback-service /etc/init.d/syncback-service
#chmod +x /etc/init.d/syncback-service
#update-rc.d syncback-service defaults
#update-rc.d syncback-service enable

INRC=$(grep "/mnt/${SF}/bashrc" "${SYNCPATH}/.bashrc" | wc -l)
if [ "$INRC" = "0" ]; then
	echo "source /mnt/${SF}/bashrc" >> "${SYNCPATH}/.bashrc"
fi

mkdir -p /mnt/${SF}/profiles/Default
mkdir -p /mnt/${SF}/bin
mkdir -p /mnt/${SF}/data
cp /media/${SF}/plain/setup/bashrc /mnt/${SF}/bashrc
chmod +x /mnt/${SF}/bashrc

cp -a /media/Vault/plain/setup/interfaces.disabled /etc/network/interfaces
cp -a /media/Vault/plain/setup/resolv.conf.disabled /etc/resolv.conf

mkdir -p /mnt/Vault/networks
cp -a /media/Vault/plain/setup/interfaces.whonix /mnt/Vault/networks/
cp -a /media/Vault/plain/setup/resolv.conf.whonix /mnt/Vault/networks/
cp -a /media/Vault/plain/setup/interfaces.clearnet /mnt/Vault/networks/
cp -a /media/Vault/plain/setup/resolv.conf.clearnet /mnt/Vault/networks/

echo "Saying 'y' speeds up boot times, but leaves potentially"
echo "important files on the VM. Make sure the VM is encrypted"
echo "or stored on an encrypted drive if you say 'y'."
echo -n "(y/n)? "
read K;
if [ "$K" == "y" ]; then
	touch /mnt/Vault/keepprofile
fi

echo "Default" > /mnt/${SF}/curprofile
echo "$SYNCPATH" > /mnt/${SF}/syncpath
echo -n "Creating default profile... "
set +e
rsync -av --delete --ignore-errors "${SYNCPATH}/" /mnt/${SF}/profiles/Default/ 1> /dev/null 2>&1
echo "[Done]"
echo ""
echo "Now reboot!"
