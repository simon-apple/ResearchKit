#!/bin/bash

scriptName=$(basename "$0")
scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ $# -ne 3 ]]; then
    echo "Usage $scriptName <Internal Xcode SDK Path> <headers-source.txt> <Target PrivateHeader Path>"
    echo "  Example:"
    echo "    $scriptName ~/Dev/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.0.Internal.sdk private-headers.txt ./PrivateHeaders"
    exit 1
fi

sdkPath=$1
xcodePath=$sdkPath/../../../../../../..
iosHeadersSourceFile=$2
targetPath=$3

if [[ ! -d "$targetPath" ]]; then
    echo "$targetPath is not a directory."
    exit 1
fi

# set -o xtrace

mkdir -p $targetPath 2>/dev/null

echo "Copying iOS headers..."
while read line
do
    if [[ $line == \#* ]]; then continue; fi
    echo "  $line"
    # Optionally, lines can specify the target subpath
    set -- $line
    headerSourcePath=$1
    headerTargetSubPath=$2
    # If the target subpath is not empty, create the directory
    [[ ! -z "$headerTargetSubPath" ]] && mkdir -p $targetPath/$headerTargetSubPath/ 2>/dev/null
    cp -R $sdkPath/$headerSourcePath $targetPath/$headerTargetSubPath/
done < $iosHeadersSourceFile
echo "done"
echo

echo "Deleting framework binaries..."
frameworkList="$(ls -d $targetPath/*.framework 2> /dev/null)"
for framework in $frameworkList
do
    frameworkBaseName=$(basename $framework)
    frameworkBaseNameNoExt=${frameworkBaseName%.*}
    echo "  $frameworkBaseName"
    rm $framework/${frameworkBaseNameNoExt} 2>/dev/null
    rm $framework/${frameworkBaseNameNoExt}.tbd 2>/dev/null
    rm $framework/${frameworkBaseNameNoExt}_debug 2>/dev/null
    rm $framework/${frameworkBaseNameNoExt}_debug.tbd 2>/dev/null
done
echo "done"
echo

echo -n "Removing internal API_AVAILABLE 'bridgeos' and 'iosmac' usage..."
find $targetPath/ -type f -print0 | xargs -0 -P 6 perl -pi -e 's|,\s*bridgeos\([\d\.,]*\)||; s|(,\s*)iosmac(\([\d\.,]*\))|$1macCatalyst$2|; s|(\(.*)iosmac(.*\))|$1macCatalyst$2|;'
echo "done"
echo

# echo -n "Fixing HealthKit..."
# find $targetPath/HealthKit.framework/ -type f -print0 | xargs -0 -P 6 perl -pi -e 's|__IOS_PROHIBITED|__SPI_AVAILABLE(ios(12.0))|'
# echo "done"
# echo

echo -n "Copying Xcode Info Text File..."
cp $xcodePath/../Xcode*.txt $targetPath/
echo "done"
echo
