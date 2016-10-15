#!/bin/bash

# Title:        unzip_and_unrar_ebooks.sh
# Author:       ikaroz <i@algorhythm.cc>
# Date:         2016-09-23
# Purpose:      Conveniently unpack eBooks from scene releases.
#               inside day/month dirs into a specified target dir.
# Usage:        Put the script in your $PATH (e.g. /usr/local/bin/),
#               and perhaps make a shorter alias for it, such as `zz'.
#               --> alias zz='unzip_and_unrar_ebooks.sh'
#               Then cd into your day/month dir and simply run `zz'.
# Dependencies: unzip unrar
# License:      GNU GPL v3.0, see the LICENSE file for more info.

version="0.9.5"



# Variable assignment
target="/home/i/Temp/"                                      ; # Where to place all books
skip1="[._-]([Ee][Pp][Uu][Bb]|[Cc][Oo][Mm][Ii][Cc])[._-]"   ; # Skip EPUB/Comic releases
skip2="\((incomplete|no-(nfo|sfv|sample))\)-"               ; # Skip (incomplete)- (no-nfo)- etc.
skip3="[._-]([Dd][Ii][Rr]|[Nn][Ff][Oo])[Ff][Ii][Xx][._-]"   ; # Skip dirfix/nfofix



red=$(tput setaf 1)
green=$(tput setaf 2)
bold=$(tput bold)
reset=$(tput sgr0)



# Runtime header
echo ""
echo -e " ${bold}unzip_and_unrar_ebooks.sh v$version (c) 2016 ikaroz <i@algorhythm.cc>$reset"
echo ""
echo " This program comes with ABSOLUTELY NO WARRANTY. This is free software,"
echo " and you are welcome to redistribute it under certain conditions."



# Make sure the destination dir exists, otherwise create it
[ ! -d "$target" ] || mkdir "$TARGET"



# Make sure the script is executed inside a day/month dir
# Valid patterns are ####-##-##, ####-##, #### (e.g. YYYY-MM-DD, YYYY-MM, MMDD)
if [[ ! ${PWD##*/} =~ ^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]|[0-9][0-9][0-9][0-9]-[0-9][0-9]|[0-9][0-9][0-9][0-9])$ ]]; then

    echo ""
    echo " We are not in a day dir or month dir:"
    echo " $bold--> $PWD$reset"
    echo ""
    echo " The script will now exit."
    echo ""

    exit 1

fi



# Using a for loop to go into each dir, unzip stuff into $target, then go into $target and unrar every archive
echo ""
echo " Starting extraction of .zip files..."
echo ""
count=0
skips=0
for dir in $(ls); do

    # If $dir is not a dir, we don't want to try to cd into it...
    if [ ! -d "$dir" -o -L "$dir" ]; then
        echo "     $dir"
        echo "     \`--> Not a directory, skipping..."
        ((skips++))
        continue
    fi

    # If $dir matches any of the skiplists, then... skip it! :)
    if [[ $dir =~ $skip1 ]]; then
        echo -e " ${red}x\e$reset $dir - skipping..."
        ((skips++))
        continue
    elif [[ $dir =~ $skip2 ]]; then
        echo -e " ${red}x$reset $dir - skipping..."
        ((skips++))
        continue
    elif [[ $dir =~ $skip3 ]]; then
        echo -e " ${red}x\e$reset $dir - skipping..."
        ((skips++))
        continue
    fi

    # Everything checks out -- enter $dir and do the magic
    cd $dir
    echo -e " ${green}o$reset $dir"
    # unzip options:
    #   -x file1 file2 *.ext    Exclude these files
    #   -d /path/to/folder/     Destination for extracted files
    #   -L                      Convert extracted files to lowercase
    unzip "*.zip" -x "file_id.diz" "*.nfo" "*.txt" -d "$target" -L > /dev/null 2>&1
    ((count++))
    cd ..

done



echo ""
echo " All zips have been extracted into \"$target\"."
echo ""
echo " Moving on to extraction of .rar archives..."
echo ""



# Go to $target and extract all .rar archives, then delete all .rar .r01 .r02 files
cd "$target"
for archive in $(ls *.rar); do

    echo -n " $archive ... "
    # unrar options:
    #   e        Extract files to current directory
    #   -c-      Do not display comments
    #   -inul    Disable all messages
    #   .y       Assume Yes on all queries
    unrar e -c- -inul -y "$archive"
    echo "OK"

done

echo ""
echo " All .rar archives have been extracted."
echo ""
echo " The .rar archives, file_id.diz, and any .txt/.nfo files, will now be removed..."

rm -f *.rar *.r[0-9][0-9] *.txt *.nfo file_id.diz



echo ""
echo -e " ${bold}All done!$reset Processed $count eBook dirs, not counting $skips skipped dirs."



exit 0
