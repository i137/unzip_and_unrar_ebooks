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



# Variable assignment
VERSION="0.9.3"
TARGET="/home/i/Temp/"                                      ; # Where to place all books
SKIP1="[._-]([Ee][Pp][Uu][Bb]|[Cc][Oo][Mm][Ii][Cc])[._-]"   ; # Skip EPUB/Comic releases
SKIP2="\((incomplete|no-nfo|no-sfv|no-sample)\)-"           ; # Skip (incomplete)- (no-nfo)- etc.
SKIP3="[._-]([Dd][Ii][Rr]|[Nn][Ff][Oo])[Ff][Ii][Xx][._-]"   ; # Skip dirfix/nfofix



# Runtime header
echo ""
echo " unzip_and_unrar_ebooks.sh v$VERSION (c) 2016 ikaroz <i@algorhythm.cc>"
echo ""
echo " This program comes with ABSOLUTELY NO WARRANTY. This is free software,"
echo " and you are welcome to redistribute it under certain conditions."



# Make sure the destination dir exists, otherwise create it
if [ ! -d "$TARGET" ]; then
    mkdir "$TARGET"
fi



# Make sure the script is executed inside a day/month dir
# Valid patterns are ####-##-##, ####-##, #### (e.g. YYYY-MM-DD, YYYY-MM, MMDD)
if [[ ! ${PWD##*/} =~ ^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]|[0-9][0-9][0-9][0-9]-[0-9][0-9]|[0-9][0-9][0-9][0-9])$ ]]; then

    echo ""
    echo " We are not in a day dir or month dir."
    echo " --> $PWD"
    echo ""
    echo " The script will now exit."
    echo ""

    exit 1

fi



# Using a for loop to go into each dir, unzip stuff into $TARGET, then go into $TARGET and unrar every archive
echo ""
echo " Starting extraction of .zip files..."
echo ""
COUNT=0
SKIPS=0
for DIR in $(ls); do

    # If $DIR is not a dir, we don't want to try to cd into it...
    if [ ! -d "$DIR" -o -L "$DIR" ]; then
        echo "     $DIR"
        echo "     \`--> Not a directory, skipping..."
        ((SKIPS++))
        continue
    fi

    # If $DIR matches any of the skiplists, then... skip it! :)
    if [[ $DIR =~ $SKIP1 ]]; then
        echo "     $DIR"
        echo "     \`--> matches $SKIP1, skipping..."
        ((SKIPS++))
        continue
    elif [[ $DIR =~ $SKIP2 ]]; then
        echo "     $DIR"
        echo "     \`--> matches $SKIP2, skipping..."
        ((SKIPS++))
        continue
    elif [[ $DIR =~ $SKIP3 ]]; then
        echo "     $DIR"
        echo "     \`--> matches $SKIP3, skipping..."
        ((SKIPS++))
        continue
    fi

    # Everything checks out -- enter $DIR and do the magic
    cd $DIR
    echo " --> $DIR"
    # unzip options:
    #   -x file1 file2 *.ext    Exclude these files
    #   -d /path/to/folder/     Destination for extracted files
    #   -L                      Convert extracted files to lowercase
    unzip "*.zip" -x "file_id.diz" "*.nfo" "*.txt" -d "$TARGET" -L > /dev/null 2>&1
    ((COUNT++))
    cd ..

done



echo ""
echo " All zips have been extracted into \"$TARGET\"."
echo ""
echo " Moving on to extraction of .rar archives..."
echo ""



# Go to $TARGET and extract all .rar archives, then delete all .rar .r01 .r02 files
cd "$TARGET"
for ARCHIVE in $(ls *.rar); do

    echo " --> $ARCHIVE"
    # unrar options:
    #   e        Extract files to current directory
    #   -c-      Do not display comments
    #   -inul    Disable all messages
    #   .y       Assume Yes on all queries
    unrar e -c- -inul -y "$ARCHIVE"

done

echo ""
echo " All .rar archives have been extracted."
echo ""
echo " The rar archives and any .txt/.nfo files will now be removed..."

rm -f *.rar *.r[0-9][0-9] *.txt *.nfo file_id.diz



echo ""
echo " All done! Processed $COUNT eBook dirs, not counting $SKIPS skipped dirs."



exit 0
