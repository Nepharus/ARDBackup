#!/bin/bash

shortName="`whoami`"

Backup ()
{
#User Confirmation to Procede
clear
echo
echo "Backup will be created at ${dir}/ARDBackup.dmg."
echo "Backup can take some time. Please be patient. Ctrl-C to abort"
echo "Press enter to continue..."
read junk

#Change Dir for backup creation
cd "${dir}" #Gets dir from Function 
#Arrays for Files/Paths
aPath[0]="/Library/Application Support/Apple/Remote Desktop/"
aPath[1]="/Library/Preferences/com.apple.RemoteDesktop.plist"
aPath[2]="/Library/Preferences/com.apple.RemoteManagement.launchd"
aPath[3]="/Library/Preferences/com.apple.RemoteManagement.plist"
aPath[4]="/Users/${shortName}/Library/Application Support/Remote Desktop/"
aPath[5]="/Users/${shortName}/Library/Preferences/com.apple.RemoteDesktop.plist"
aPath[6]="/var/db/RemoteManagement/"

DBBack[0]="${dir}/ARDdbBackup/01"
DBBack[1]="${dir}/ARDdbBackup/02"
DBBack[2]="${dir}/ARDdbBackup/03"
DBBack[3]="${dir}/ARDdbBackup/04"
DBBack[4]="${dir}/ARDdbBackup/05"
DBBack[5]="${dir}/ARDdbBackup/06"
DBBack[6]="${dir}/ARDdbBackup/07"

#Making Directories and Loop to Cycle through and copy array elements
echo "Making Directories..."
for ((count=0; count<7; count++)); do
	if [ -e "${aPath[count]}" ]; then
	mkdir -p "${DBBack[count]}"
	echo "Backing Up files..."
	sudo ditto "${aPath[count]}" "${DBBack[count]}"
	fi
done

#Compressed DMG of Backup
echo "Creating Compressed Backup..."
sudo hdiutil create -srcfolder "${dir}/ARDdbBackup" "${dir}/ARDBackup.dmg"

#Clean up
sudo rm -rf "${dir}/ARDdbBackup"
sudo -k
}

Restore ()
{
cd "${dir}"
#make mount point
mkdir ${dir}/ARDdbBackup
	
#make mount point and mount dmg
sudo hdiutil attach -mountpoint "${dir}/ARDdbBackup" "${dir}/ARDBackup.dmg"

#array for Paths to be used
DBBack[0]="${dir}/ARDdbBackup/01"
DBBack[1]="${dir}/ARDdbBackup/02"
DBBack[2]="${dir}/ARDdbBackup/03"
DBBack[3]="${dir}/ARDdbBackup/04"
DBBack[4]="${dir}/ARDdbBackup/05"
DBBack[5]="${dir}/ARDdbBackup/06"
DBBack[6]="${dir}/ARDdbBackup/07"

aPath[0]="/Library/Application Support/Apple/Remote Desktop/"
aPath[1]="/Library/Preferences/"
aPath[2]="/Library/Preferences/"
aPath[3]="/Library/Preferences/"
aPath[4]="/Users/${shortName}/Library/Application Support/Remote Desktop/"
aPath[5]="/Users/${shortName}/Library/Preferences/"
aPath[6]="/var/db/RemoteManagement/"

for ((count=0; count<7; count++)); do
	if [ -e "${DBBack[count]}" ]; then
	echo "Restoring files..."
	sudo ditto "${DBBack[count]}" "${aPath[count]}"
	fi
done

#find disk number
disk=`mount | grep "ARDdbBackup" | awk '{print $1}'`
sudo hdiutil detach "${disk}"

#clean up 
rm -rf ${dir}/ARDdbBackup
sudo -k
}

#Menu of Choices
Menu ()
{
	clear
	echo
	echo "Enter the Number of what you'd like to do"
	echo 
	echo "1 - Backup ARD Database Files"
	echo "2 - Restore ARD Database Files"
	echo "3 - Exit"
	read choice
}

GetPathBackup ()
{
	echo "Choose where backup should be saved: Opening prompt....."
	dir=`osascript<<END
			tell application "System Events"
			activate
				set dest to choose folder with prompt "Choose Destination of Backup"
				set POSIXdest to POSIX path of dest
				return POSIXdest
			end tell
			END`
}

GetPathSource ()
{
	echo "Choose where the backup is saved: Opening Prompt..."
	back=`osascript<<END
			tell application "System Events"
			activate
				set dest to choose file with prompt "Where is the Backup located?"
				set POSIXdest to POSIX path of dest
				return POSIXdest
			end tell
			END`
	dir=`dirname "${back}"`
}

FileCheck ()
{
# Error Check for exsisting file...
if [ -e "${dir}/ARDBackup.dmg" ]; then
	echo "Backup already Exists."
	echo "1 - Replace Existing backup"
	echo "2 - Abort"
	read answer
	
	#Variable to control While loop
	check=0

	while (( check != 1 ))	#Used for input validation
	do
	
		#Conditional to determine choice
		case $answer in

			"1" )
				rm -rf "${dir}/ARDBackup.dmg"
				check="1" 	#Exits the Loop
				;;
			"2" )
				exit 0
				;;
			* )
				echo "Invalid Choice please re-run with valid choice:"
				echo "Backup already Exists."
				echo "1 - Replace Existing backup"
				echo "2 - Abort"
				sleep 3
				control="0"	#Will repeat the choices
				;;
		esac
	done
fi
}

FinNotify ()
{
junk=`osascript<<END
			tell application "System Events"
			activate
				display dialog "Operation Completed"
				return
			end tell
			END`
}


##########MAIN BODY#####################

#Variable to control While loop
control=0

while (( control != 1 ))	#Used for input validation
do

	Menu 
	
	#Conditional to determine choice
	case $choice in

		"1" )
			GetPathBackup
			FileCheck
			Backup
			FinNotify
			control="1" 	#Exits the Loop
			;;
		"2" )
			GetPathSource
			Restore
			FinNotify
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