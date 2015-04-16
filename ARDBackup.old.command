#!/bin/bash

#ARD Backup!

#Change Working directory to the scripts dir
dir=`dirname "$0"`
cd "$dir"

#Run Script with root permissions
# if [ `whoami` != "root" ]; then
# 	whoami >> name
#	exec sudo $0
# fi
 
#Get Shortname for file
shortName="`whoami`"

item1="/Library/Application Support/Apple/Remote Desktop/"
item2="/Library/Preferences/com.apple.RemoteDesktop.plist"
item3="/Library/Preferences/com.apple.RemoteManagement.launchd"
item4="/Library/Preferences/com.apple.RemoteManagement.plist"
item5="/Users/${shortName}/Library/Application Support/Remote Desktop/"
item6="/Users/${shortName}/Library/Preferences/com.apple.RemoteDesktop.plist"
item7="/var/db/RemoteManagement/"

DBBack1="${dir}/ARDdbBackup/01"
DBBack2="${dir}/ARDdbBackup/02"
DBBack3="${dir}/ARDdbBackup/03"
DBBack4="${dir}/ARDdbBackup/04"
DBBack5="${dir}/ARDdbBackup/05"
DBBack6="${dir}/ARDdbBackup/06"
DBBack7="${dir}/ARDdbBackup/07"

Backup ()
{
#Make backup Dirs and Organized
for ((count=1; count<8; count++)); do
	mkdir -p "${dir}/ARDdbBackup/0${count}"
done

echo "Note: Item 7 Can take a while to backup. Please be patient."
echo "Please enter your Password"

#BackUp Needed items
sudo ditto "$item1" "$DBBack1"
echo "Item 1....."

echo "Item 2....."
sudo ditto "$item2" "$DBBack2"

echo "Checking item 3"
if [ -e "$item3" ]; then
echo "Item 3....."
sudo ditto "$item3" "$DBBack3"
else echo "Item 3 is not present. Non essential item Skipping..."
fi

echo "Item 4....."
sudo ditto "$item4" "$DBBack4"

echo "Item 5....."
ditto "$item5" "$DBBack5"

echo "Item 6....."
ditto "$item6" "$DBBack6"

echo "Item 7....."
sudo ditto "$item7" "$DBBack7"

#compressed DMG
sudo hdiutil create -src "${dir}/ARDdbBackup" "${dir}/ARDBackup.dmg"

#clean up
rm -rf "${dir}/ARDdbBackup"
sudo -k
}

Restore ()
{
mkdir "${dir}/ARDdbBackup"
sudo hdiutil attach -mountpoint "${dir}/ARDdbBackup" "${dir}/ARDBackup.dmg"

echo "Item 1....."
sudo ditto "$DBBack1" "$item1"

echo "Item 2....."
sudo ditto "$DBBack2" "/Library/Preferences/"

echo "Item 3....."
sudo ditto "$DBBack3" "/Library/Preferences/"

echo "Item 4....."
sudo ditto "$DBBack4" "/Library/Preferences/"

echo "Item 5....."
ditto "$DBBack5" "$item5"

echo "Item 6....."
ditto "$DBBack6" "/Users/${shortName}/Library/Preferences/"

echo "Item 7....."
sudo ditto "$DBBack7" "$item7"

#cleanup
sudo -k
}

#Menu of Choices
Menu ()
{
	echo
	echo "Enter the Number of what you'd like to do"
	echo 
	echo "1 - Backup ARD Database Files"
	echo "2 - Restore ARD Database Files"
	echo "3 - Exit"
	read choice
}

#Variable to control While loop
control=0

while (( control != 1 ))	#Used for input validation
do

	Menu 
	
	#Conditional to determine choice
	case $choice in

		"1" )
			Backup
			
			control="1" 	#Exits the Loop
			;;
		"2" )
			Restore
			control="1"
			;;
		"3" )
			control="1"
			;;
		* )
			echo "Invalid Choice please re-run with valid choice"
			sleep 3
			control="0"	#Will repeat the choices
			;;
	esac
done

exit 0
	
