FROM ubuntu:latest

ARG ANDROID_SDK_VERSION="33"
ARG ANDROID_BUILD_TOOLS_VERSION="33.0.2"
ARG FLUTTER_VERSION="stable"


RUN \
    apt-get update && \
    apt-get install -y \
        file curl tar zip unzip libarchive-tools git adb xz-utils

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
    mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools/latest" && \
    curl -SL "https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip" | \
        bsdtar xvf - -C "${ANDROID_SDK_ROOT}/cmdline-tools/latest/" --strip-components=1 "cmdline-tools" && \
    chmod +x ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/*


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


RUN \
    if [ -d "${FLUTTER_HOME}/bin/cache/artifacts/engine/linux-arm64" ] && [ ! -d "${FLUTTER_HOME}/bin/cache/artifacts/engine/linux-arm64/shader_lib" ]; then \
        cd "${FLUTTER_HOME}" && \
        curl -SL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$(git describe --tags)-stable.tar.xz" | \
            tar Jxvf - -C "${FLUTTER_HOME}/bin/cache/artifacts/engine/linux-arm64/" --strip-components=6 "flutter/bin/cache/artifacts/engine/linux-x64/shader_lib"; \
    fi


WORKDIR "/home/devel"
