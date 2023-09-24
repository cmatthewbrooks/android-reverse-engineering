#!/bin/bash

#set -x

# This value needs to be whatever was used when the image was built
IMAGE="android-re"

TIMESTAMP=$(date +%s)
TARGET_APK=$1
FNAME=$(basename "$TARGET_APK" | cut -d. -f1)
WORKING_DIR="/private/tmp/$TIMESTAMP-$FNAME-autoapk"
ORIGINAL_COPY="$WORKING_DIR/original.apk"
UNZIPPED="unzipped"
APKTOOL="apktool"

mkdir -p $WORKING_DIR
cd $WORKING_DIR

cp $TARGET_APK $ORIGINAL_COPY

echo "[+] Unzipping APK..."
mkdir -p $UNZIPPED
unzip -qq $ORIGINAL_COPY -d $UNZIPPED
echo "[+] Unzipping APK...DONE"

echo "[+] Extracting with apktool..."
docker run --rm -it -v $PWD:/data $IMAGE /tools/apktool/apktool d "original.apk" -o $APKTOOL
echo "[+] Extracting with apktool...DONE"

echo "[+] Extracting with dex2jar..."
docker run --rm -it -v $PWD:/data $IMAGE /tools/dex-tools/d2j-dex2jar.sh $UNZIPPED/classes.dex -o "dex2jar.jar"
echo "[+] Extracting with dex2jar...DONE"

echo "[+] Decompiling with jd-cli..."
mkdir -p "jd"
docker run --rm -it -v $PWD:/data $IMAGE /tools/jd-cmd/jd-cli -od "jd" "dex2jar.jar"
echo "[+] Decompiling with jd-cli...DONE"
