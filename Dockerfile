FROM registry.fedoraproject.org/fedora-minimal:latest

ARG ANDROID_SDK_VERSION="33"
ARG ANDROID_BUILD_TOOLS_VERSION="33.0.2"
ARG FLUTTER_VERSION="stable"


RUN \
    microdnf update -y && \
    microdnf install -y \
        curl tar zip unzip git adb xz

ENV HOME="/home/devel"

ENV JAVA_HOME="/opt/java/openjdk"

ENV ANDROID_HOME="${HOME}/tools/android-sdk"
ENV ANDROID_SDK_ROOT="${ANDROID_HOME}"
ENV ANDROID_BUILD_TOOLS_VERSION="${ANDROID_BUILD_TOOLS_VERSION}"

ENV FLUTTER_HOME="${HOME}/tools/flutter"

ENV PATH="${JAVA_HOME}/bin:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${FLUTTER_HOME}/bin:${PATH}"


COPY --from=docker.io/eclipse-temurin:11 $JAVA_HOME $JAVA_HOME


RUN useradd -ms /bin/bash -d $HOME devel

USER devel


RUN \
    mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    cd /tmp && \
    curl -SL "https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip" | jar xvf /dev/stdin && \
    mv -v /tmp/cmdline-tools "${ANDROID_SDK_ROOT}/cmdline-tools/latest" && \
    chmod +x $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/*


RUN \
    yes | sdkmanager --licenses && \
    sdkmanager --verbose \
        "platform-tools" \
        "platforms;android-${ANDROID_SDK_VERSION}" \
        "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" && \
    ln -sf "/usr/bin/adb" "${ANDROID_SDK_ROOT}/platform-tools/adb"


RUN \
    git clone https://github.com/flutter/flutter.git --depth 1 -b "${FLUTTER_VERSION}" --single-branch "${FLUTTER_HOME}" && \
    git config --global --add safe.directory "${FLUTTER_HOME}" && \
    rm -rf "${FLUTTER_HOME}/bin/cache" && \
    flutter precache && \
    flutter config --no-enable-linux-desktop && \
    yes | flutter doctor --android-licenses


WORKDIR "/home/devel"
