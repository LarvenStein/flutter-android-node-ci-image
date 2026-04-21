FROM ghcr.io/catthehacker/ubuntu:act-latest

ENV ANDROID_HOME=/opt/android
ENV FLUTTER_HOME=/opt/flutter

# Java
RUN apt-get update -qq && apt-get install -y openjdk-17-jdk-headless && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Android SDK
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d $ANDROID_HOME/cmdline-tools && \
    mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

RUN yes | sdkmanager --licenses || true && \
    sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"
    
# Flutter
RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git $FLUTTER_HOME
ENV PATH=$PATH:$FLUTTER_HOME/bin
ENV TAR_OPTIONS="--no-same-owner"
RUN flutter precache --android --no-ios && \
    chmod -R 777 /opt/flutter/bin/cache
