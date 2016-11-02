#!/bin/sh
#Info: Install and deploy V-Ray from zip file for OSX and Linux. Original filenames V-Ray zip filenames should be used for the script to work properly. The script will automatically extract the .zip V-Ray package, edit the necessary config files, set the environment variables and deploy Maya with V-Ray.
#Usage: ./run_vray_from_zip.sh <vray_LLL_VVVVV_mayaNNNN_linux_x64> - where LLL is the license type, VVVVV is the version number and NNNN is the maya version. See the below instructions for more details

#Instructions:
#Step 1: Download the <vray4maya>.zip.rar package
#Step 2: Extract it. This will create expose the .zip archive. You need to pass its filename as an argument to the script.
#Step 3: Navigate to the directory where "run_vray_from_zip.sh" is located from a terminal
#Step 4: execute the script. Pass the .zip V-Ray for Maya package as an argument.
#Example: ./run_vray_from_zip.sh vray_adv_34004_maya2017_linux_x64.zip

reset
fname="$1"
fname=${fname%.*}
os=`uname`

bldcheck() {
bcheck=`echo $fname | cut -c 6-9`
if test "$bcheck" = "demo"
    then
        initDemo
    else    
	   initAdv
fi
}

initDemo() {
btch=`echo $fname | cut -c 25-25`
if test "$btch" = "."
    then
	   mver=`echo $fname | cut -c 21-26`
	   menv=`echo $fname | cut -c 21-24`_5
       install
    else
       mver=`echo $fname | cut -c 21-24`
       menv=`echo $fname | cut -c 21-24`
       install
fi
}

initAdv() {
btch=`echo $fname | cut -c 24-24`
if test "$btch" = "."
    then
	   mver=`echo $fname | cut -c 20-25`
       menv=`echo $fname | cut -c 20-24`_5
       install
    else
	   mver=`echo $fname | cut -c 20-23`
	   menv=`echo $fname | cut -c 20-23`
       install
fi
}

startLinux() {
#checking Maya version existance Linux
mayal=/usr/autodesk/maya$mver/bin/maya$mver
echo
if [ -f $mayal ]
    then
        echo Starting Maya $mver
        echo _______________________________________
        echo
	   $mayal
    else
	   echo Maya $mver for Linux is not installed. Please install it and run the zip instalation again. 
       echo Exiting...
    	exit
fi
}

startDarwin() {
#checking Maya version existance OSX
mayax=/Applications/Autodesk/maya$mver/Maya.app/Contents/MacOS/Maya
echo
if [ -f $mayax ]
    then
        echo Starting Maya $mver
        echo _________________________________________
        echo
        $mayax
    else
        echo Maya $mver for OSX is not installed. Please install it and run the zip instalation again. 
        echo Exiting...
	exit
fi
}

install() {
echo Installing V-Ray for Maya $mver
echo _________________________________________
cpath="${PWD}"
echo
echo Extracting $fname.zip 
unzip -o -q "$cpath/$fname" -d "$fname/"

#Checking OS and setting environment variables
if test "$os" == "Darwin"
    then
        export DYLD_LIBRARY_PATH=$cpath/$fname/maya_root/Maya.app/Contents/MacOS:$DYLD_LIBRARY_PATH
	export XBMLANGPATH=$cpath/$fname/maya_vray/icons:$XBMLANGPATH
        sedx="sed -i .bak "
    else
        export LD_LIBRARY_PATH=$cpath/$fname/maya_root/lib:$LD_LIBRARY_PATH
	export XBMLANGPATH=$cpath/$fname/maya_vray/icons/%B:$XBMLANGPATH
        os=Linux
        sedx="sed -i "
fi

export PYTHONPATH=$cpath/$fname/maya_vray/scripts:$PYTHONPATH
export MAYA_SCRIPT_PATH=$cpath/$fname/maya_vray/scripts:$MAYA_SCRIPT_PATH
export MAYA_PLUG_IN_PATH=$cpath/$fname/maya_vray/plug-ins:$MAYA_PLUG_IN_PATH
export VRAY_AUTH_CLIENT_FILE_PATH=$HOME/.ChaosGroup
export VRAY_FOR_MAYA"$menv"_MAIN_x64="$cpath/$fname/maya_vray"
export VRAY_FOR_MAYA"$menv"_PLUGINS_x64="$cpath/$fname/maya_vray/vrayplugins"
export PATH=$cpath/$fname/maya_root/bin:$PATH
export VRAY_OSL_PATH_MAYA"$menv"_x64="$cpath/$fname/vray/opensl"
export MAYA_RENDER_DESC_PATH=$cpath/$fname/maya_root/bin/rendererDesc
echo
echo

#printing the environment variables
echo Environment variables set:
echo _________________________________________
echo
if test "$os" == "Darwin"
    then
        echo DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH
    else
        echo LD_LIBRARY_PATH=$LD_LIBRARY_PATH
fi

env | grep -E "^(VRAY.*MAYA$mver|PATH|XBMLANGPATH|PYTHONPATH|DYLD_LIBRARY_PATH|LD_LIBRARY_PATH)"
echo
#echo _________________________________________
writeconf
}

writeconf() {
#writing the vrayconfig.xml for IPR support
confxml=$cpath/$fname/maya_vray/bin/vrayconfig.xml
vconf=$cpath/$fname/maya_vray/bin/vray
vconffl="$cpath/$fname/maya_vray"
stdconf="$cpath/$fname/vray"
$sedx 's/\[//g' "$confxml"
$sedx 's/\]//g' "$confxml"
$sedx 's|PLUGINS|'"${vconffl}"'|g' "$confxml"

#writing the vray bash script for IPR support
$sedx 's/\[//g' "$vconf"
$sedx 's/\]//g' "$vconf"
$sedx 's|PLUGINS|'"$vconffl"'|g' "$vconf"
$sedx 's|STDROOT|'"$stdconf"'|g' "$vconf"
echo _________________________________________
echo Installation complete.

start$os
}

#main
if [ -z "$1" ];
then
	echo
	echo No zip file selected. Please select a zip file.
	echo
	echo Instructions:
	echo Step 1: Download the vray4maya.zip.rar package
	echo Step 2: Extract it. This will create expose the .zip archive. You need to pass its filename as an argument to the script.
	echo Step 3: Navigate to the directory where "run_vray_from_zip.sh" is located from a terminal
	echo Step 4: execute the script. Pass the .zip V-Ray for Maya package as an argument.
	echo Example: ./run_vray_from_zip.sh vray_adv_34004_maya2017_linux_x64.zip
	echo _________________________________________
 else
    bldcheck
fi
