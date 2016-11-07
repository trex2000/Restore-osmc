#!/bin/bash
filename="backup_hts"`date +"%d-%m-%Y"`".zip" 
zip -0  $filename -r /home/.hts
if grep -qs '/media/hdd' /proc/mounts; then
    mv $filename /media/hdd/backup/$filename
else
    echo "Network drive not mounted. Cannot copy backup"
fi
