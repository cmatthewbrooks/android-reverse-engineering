# Android Reverse Engineering

> A very basic introduction to reverse engineering (in general and for Android) as well as some useful tools (apktool, dex2jar, jd-cmd) packed into a single Docker container to make it easy to play around with these tools.

## Installation / Usage / TL;DR

The provided `Dockerfile` within this repository contains everything you need. Just build the image and run your commands within containers based on that image.

### Build

You may want to replace with your own namespaces and names.

```shell
docker build -t android-re .
```

### Run

Again, you may want to replace with your own namespaces and names.

```shell
docker run --rm -v "$PWD/data:/data" android-re {COMMAND}
```

The container’s workdir is `/data`. `/tools` contains all the required tools.

- Running apktool → `/tools/apktool/apktool`
- Running dex2jar → `/tools/dex-tools/d2j-dex2jar.sh`
- Running jd-cmd → `/tools/jd-cmd/jd-cli`

You can use the `autoapk.sh` script to take a target APK, move it to an analysis-specific
working directory in `/private/tmp`, and run the tools over it.

```
./autoapk.sh /path/to/target.apk
```

## APK structure

An APK (»Android application package«) is nothing but a ZIP archive at first glance, containing the Android Manifest (`AndroidManifest.xml` → Binary XML), all classes in »Dalvik Executable« format (`classes.dex`), and compiled resources (`resources.arsc`) as well as uncompiled resources (`res` directory). Android’s virtual execution environment »Dalvik virtual machine« doesn’t process conventional Java binaries (`.class` files) but its own bytecode format, the »Dalvik Executable Format« (`.dex`). The conversion of `.class` to `.dex` happens during development via »dx«, which is part of the Android development environment (SDK).The unpacked file `classes.dex` therefore contains the definitions of all classes as bytecode.

## Decompilation

While there’s no tool to decompile APKs into `.java` files 100% reliably, there are two ways that allow decompiling classes and resources as accurate as possible. However, the focus of decompilation in reverse engineering is on generating human-readable codes rather than a fully-functional code base. A combination of the following two decompilation methods usually delivers the most useful results.

### Decompilation using apktool

apktool is based on »[smali](https://github.com/JesusFreke/smali)« and »[baksmali](https://github.com/JesusFreke/smali)«, an assembler and disassembler for the DEX format, which is used by the Dalvik VM. baksmali disassembles the packed classes from the `classes.dex` file and saves the classes as files in smali syntax (`.smali` files). This is the direct output of the disassembly of the VM-language and also the most reliable way to evaluate what the code is exactly doing. The smali syntax is thus a readable form of Android bytecode.

- Decompilation: `apktool d com.facebook.katana.apk -o facebook`
- Reassmebly: `apktool b com.facebook.katana.apk -o fb-rebuild.apk`

A great advantage of apktool is that not only the pure classes get decompiled, but also several XML resources included in the APK.

### Decompilation using dex2jar and JD-CMD

By using the previously unzipped `classes.dex` and running `d2j-dex2jar.sh classes.dex -o classes.jar`, it’s possible to convert all classes into a Java Archive (`.jar`). The resulting Java archives can be decompiled using the »Java Decompiler«. Unfortunately, JD is only provided as a GUI tool as well as in the form of plug-ins for IDEs right now. »jd-cmd« is a CLI version of the decompiler and can be used to extract the classes.

Nevertheless, »[JD-GUI](http://jd.benow.ca/)« (not included within this repository) is a great way to view the Java source code of individual classes directly in an Eclipse-like interface and export the Java code into a ZIP archive using »Save All Sources« in the menu.

Combined with the resources gained through the apktool, the exported files can be imported into an IDE (e.g. into Eclipse → »Create project from existing source«) and inspected/processed in detail.

## Changelog

* 0.0.1
  * Initial version
* 0.0.2
  * Forked and updated

## License

Copyright (c) 2015 [Thomas Rasshofer](http://thomasrasshofer.com/)  
Licensed under the MIT license.

See LICENSE for more info.
