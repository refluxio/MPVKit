#!/bin/bash
# 把 iOS xcframework 切片合并进已有的 macOS xcframework，产出支持 iOS+macOS 的多平台 xcframework。
# 前提：已运行过 download_xcframeworks.sh，libmpv/ 目录里有 macos 切片。
set -e

RELEASE="v0.7.2"
BASE="https://github.com/media-kit/libmpv-darwin-build/releases/download/${RELEASE}"
IOS_VARIANT="ios-universal-video-default"
DEST="$(dirname "$0")/libmpv"

LIBS=(Mpv Avcodec Avfilter Avformat Avutil Swresample Swscale Ass Dav1d Freetype Fribidi Harfbuzz Mbedcrypto Mbedtls Mbedx509 Png16 Uchardet Xml2)

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

for lib in "${LIBS[@]}"; do
    MERGED="${DEST}/${lib}.xcframework"

    # 已合并过（有 ios 目录）则跳过
    if ls "${MERGED}" 2>/dev/null | grep -q "^ios-"; then
        echo "Skipping ${lib} (already has iOS slice)"
        continue
    fi

    echo "Merging ${lib}..."

    # 下载 iOS xcframework
    IOS_ZIP="libmpv-xcframeworks_${RELEASE}_${IOS_VARIANT}_${lib}.zip"
    curl -fL --progress-bar "${BASE}/${IOS_ZIP}" -o "${TMPDIR}/${IOS_ZIP}"
    IOS_DIR="${TMPDIR}/${lib}_ios"
    mkdir -p "${IOS_DIR}"
    unzip -q "${TMPDIR}/${IOS_ZIP}" -d "${IOS_DIR}/"

    # 找到 iOS xcframework 目录
    IOS_XCFW=$(find "${IOS_DIR}" -name "${lib}.xcframework" -maxdepth 3 | head -1)
    if [ -z "${IOS_XCFW}" ]; then
        echo "ERROR: Could not find ${lib}.xcframework in iOS download"
        continue
    fi

    # 收集所有 .framework 路径（macOS + iOS）
    FW_ARGS=""
    # macOS 切片
    while IFS= read -r fw; do
        FW_ARGS="${FW_ARGS} -framework ${fw}"
    done < <(find "${MERGED}" -name "${lib}.framework" -maxdepth 4)
    # iOS 切片
    while IFS= read -r fw; do
        FW_ARGS="${FW_ARGS} -framework ${fw}"
    done < <(find "${IOS_XCFW}" -name "${lib}.framework" -maxdepth 4)

    if [ -z "${FW_ARGS}" ]; then
        echo "ERROR: No frameworks found for ${lib}"
        continue
    fi

    # 合并
    MERGED_TMP="${TMPDIR}/${lib}_merged.xcframework"
    eval xcodebuild -create-xcframework ${FW_ARGS} -output "${MERGED_TMP}" 2>&1 | grep -v "^$"

    # 替换
    rm -rf "${MERGED}"
    mv "${MERGED_TMP}" "${MERGED}"
    echo "  -> ${lib} merged OK"
done

xattr -dr com.apple.quarantine "${DEST}/" 2>/dev/null || true
echo "Done. All xcframeworks now support macOS + iOS."
