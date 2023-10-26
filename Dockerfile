# docker build --progress=plain -t android-re:latest  . &> build.log

FROM ubuntu:22.04

ENV DEX_TOOLS_VERSION "v2.3"
ENV APKTOOL_VERSION "2.8.1"
ENV JD_CLI_VERSION "jd-cli-1.2.1"

RUN DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update
RUN apt-get -yqq upgrade

RUN apt-get install -yqq --force-yes unzip wget maven openjdk-11-jdk

RUN mkdir /tools

# Install Dex Tools

RUN wget -q -O "dex-tools.zip" "https://github.com/pxb1988/dex2jar/releases/download/$DEX_TOOLS_VERSION/dex2jar-v2.zip"
RUN unzip -q "dex-tools.zip" -d /tools
RUN mv "/tools/dex2jar-$DEX_TOOLS_VERSION" "/tools/dex-tools"
RUN find "/tools/dex-tools" -type f -name "*.sh" -exec chmod +x {} \;

# Install APK Tool

RUN mkdir /tools/apktool
RUN wget -q -O "/tools/apktool/apktool" "https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool"
RUN chmod +x "/tools/apktool/apktool"
RUN wget -q -O "/tools/apktool/apktool.jar" "https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_$APKTOOL_VERSION.jar"
RUN chmod +x "/tools/apktool/apktool.jar"

# Install jd-cmd

RUN wget -q -O "jd-cli.zip" "https://github.com/intoolswetrust/jd-cli/archive/refs/tags/$JD_CLI_VERSION.zip"
RUN unzip -q "jd-cli.zip" -d .
RUN mv "jd-cli-$JD_CLI_VERSION" jd-cli
RUN cd jd-cli && pwd && ls && mvn package
RUN mkdir /tools/jd-cli
RUN cp /jd-cli/jd-cli/target/jd-cli.jar /tools/jd-cli/jd-cli

RUN apt-get autoremove -yqq
RUN apt-get clean
RUN rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /data
VOLUME ["/data"]
