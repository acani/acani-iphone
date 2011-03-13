#!/bin/sh

# script to screenshot the iPhone Simulator to the correct size
# to upload to iTunes Connect
# written by Jehiah Czebotar http://jehiah.cz/

OUTPUTDIR=~/Desktop
TEMPFILE=iPhoneSimulatorScreenshot_`date +%Y%m%d_%H%M%S`.png

echo "output filename:\c"
read -e OUTPUTFILE

# activate iPhone Simulator so it's easy to click on 
osascript -e 'tell application "iPhone Simulator"' -e 'activate' -e 'end tell'

# capture the screen
screencapture -iowW $OUTPUTDIR/$TEMPFILE 

# resize to the apple upload size, 320x480
# sips -c 480 320 $OUTPUTDIR/$TEMPFILE --out $OUTPUTDIR/$OUTPUTFILE
