#!/bin/bash
#Place this script in your Bitcoin folder (e.g. /home/[user]/.bitcoin)

#Replace with the path to your node file
nodepath=~/Desktop/Node/blocks/
#Replace with the path on your external hard drive to move the blk and rev files
harddrivepath="/media/corey/My Passport/Node"

#Go into blocks folder to collect info
cd blocks

#Begin the main loop that is repeated every ____ seconds depending on the number after "sleep" at the bottom
while true; do

    #Not necessary but just in case, this emptys the arrays we fill with the blk and rev file info
    unset filelist
    unset movedfiles

    #Collect a list of the rev files in the .bitcoin/blocks folder
    for filename in rev*.dat;do filelist+=(${filename:3:5}); done
    #Collect a list of the rev files already moved to the external hard drive
    for filename in "$harddrivepath"/rev*.dat;do movedfiles+=(${filename:33:-4}); done

    #Identify the file most recent file number moved plus 1 (aka start from where you left off)
    loop=${#movedfiles[@]}

    #Loop from the previous file number to the 3rd most recent. This leaves at least two blk and rev files on a the local machine which I have found to improve startup time for Bitcoin Core
    while [ $loop -le "$(( ${#filelist[@]} - 3 ))" ]; do
        
        #Move the blk and rev files of a particular file number and create symbolic links so Bitcoin Core can find them later if necessary
        mv "blk${filelist[$loop]}.dat" "$harddrivepath"
        ln -s "$harddrivepath/blk${filelist[$loop]}.dat" "$nodepath"
        mv "rev${filelist[$loop]}.dat" "$harddrivepath"
        ln -s "$harddrivepath/rev${filelist[$loop]}.dat" "$nodepath"

        loop=$(( $loop + 1 ))

    done

    #This leaves a 5 minute gap, which is good for a node that is already synced. If you are starting from genesis, you might want to go shorter, but I had failures when starting from genesis with a 5 second sleep period. Not sure why. 
    sleep 300

    clear

done
