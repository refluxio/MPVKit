#!/bin/bash
set -e
RELEASE="v0.7.2"
BASE="https://github.com/media-kit/libmpv-darwin-build/releases/download/${RELEASE}"
VARIANT="macos-universal-video-default"
DEST="$(dirname "$0")/libmpv"

mkdir -p "${DEST}"
LIBS=(Mpv Avcodec Avfilter Avformat Avutil Swresample Swscale Ass Dav1d Freetype Fribidi Harfbuzz Mbedcrypto Mbedtls Mbedx509 Png16 Uchardet Xml2)

for lib in "${LIBS[@]}"; do
    FRAMEWORK="${DEST}/${lib}.xcframework"
    if [ -d "${FRAMEWORK}" ]; then
        echo "Skipping ${lib} (already exists)"
        continue
    fi
    ZIP="libmpv-xcframeworks_${RELEASE}_${VARIANT}_${lib}.zip"
    echo "Downloading ${lib}..."
    curl -fL --progress-bar "${BASE}/${ZIP}" -o "/tmp/${ZIP}"
    unzip -q "/tmp/${ZIP}" -d "${DEST}/"
    rm "/tmp/${ZIP}"
done

xattr -dr com.apple.quarantine "${DEST}/" 2>/dev/null || true
echo "Done. Frameworks in ${DEST}/"
