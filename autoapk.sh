#!/bin/bash

# set -x

# This value needs to be whatever was used when the image was built
IMAGE="android-re"

TIMESTAMP=$(date +%s)
TARGET_APK=$1
FNAME=$(basename "$TARGET_APK" | cut -d. -f1)
WORKING_DIR="/private/tmp/$TIMESTAMP-$FNAME-autoapk"
ORIGINAL_COPY="$WORKING_DIR/original.apk"
UNZIPPED="$WORKING_DIR/unzipped"
APKTOOL="$WORKING_DIR/apktool"


if ! docker info > /dev/null 2>&1; then
  echo "This script uses docker, and it isn't running - please start docker and try again!"
  exit 1
fi


mkdir -p $WORKING_DIR
cp $TARGET_APK $ORIGINAL_COPY

echo "[+] Unzipping APK..."
mkdir -p $UNZIPPED
unzip -o -qq $ORIGINAL_COPY -d $UNZIPPED
echo "[+] Unzipping APK...DONE"

echo "[+] Extracting with apktool..."
docker run --rm -it -v $WORKING_DIR:/data $IMAGE /tools/apktool/apktool d "original.apk" -o "apktool"
echo "[+] Extracting with apktool...DONE"

echo "[+] Extracting with dex2jar..."
docker run --rm -it -v $WORKING_DIR:/data $IMAGE /tools/dex-tools/d2j-dex2jar.sh "unzipped/classes.dex" -o "dex2jar.jar"
echo "[+] Extracting with dex2jar...DONE"

echo "[+] Decompiling with jd-cli..."
mkdir -p "jd"
docker run --rm -it -v $WORKING_DIR:/data $IMAGE java -jar /tools/jd-cli/jd-cli -ods "classes_decompiled" -g ALL "dex2jar.jar"
echo "[+] Decompiling with jd-cli...DONE"
