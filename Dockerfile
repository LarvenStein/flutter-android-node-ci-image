FROM debian:trixie-slim

ENV ANDROID_HOME=/opt/android
ENV FLUTTER_HOME=/opt/flutter

# Base dependencies
RUN apt-get update -qq && apt-get install -y \
    wget \
    unzip \
    zip \
    curl \
    git \
    xz-utils \
    libglu1-mesa \
    nodejs \
    python3 \
    bash \
    file \
    which \
    openjdk-21-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

# Android SDK
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d $ANDROID_HOME/cmdline-tools && \
    mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

RUN yes | sdkmanager --licenses || true && \
    sdkmanager "platform-tools" \
               "platforms;android-34" \
               "platforms;android-35" \
               "platforms;android-36" \
               "build-tools;35.0.0" \
               "ndk;28.2.13676358" \
               "cmake;3.22.1"

# Flutter - pinned to exact tag commit via full clone
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME && \
    cd $FLUTTER_HOME && \
    git checkout 3.38.9

ENV PATH=$PATH:$FLUTTER_HOME/bin
ENV TAR_OPTIONS="--no-same-owner"

# Pre-warm Flutter tool and Android artifacts
RUN flutter precache --android && \
    chmod -R 777 $FLUTTER_HOME/bin/cache
