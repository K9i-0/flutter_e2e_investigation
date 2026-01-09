#!/usr/bin/env bash
# Android エミュレーター起動スクリプト
# dev (開発) / ci (高速・ヘッドレス) モード対応

set -e

# ANDROID_HOME チェック
if [ -z "$ANDROID_HOME" ]; then
    echo "Error: ANDROID_HOME is not set."
    echo "Please set ANDROID_HOME to your Android SDK location."
    exit 1
fi

MODE="${1:-dev}"
AVD_NAME="${2:-E2E_Optimized}"
SNAPSHOT_NAME="${3:-e2e_ready}"
EMULATOR_PATH="$ANDROID_HOME/emulator/emulator"
BOOT_TIMEOUT=120

usage() {
    echo "Usage: $0 [MODE] [AVD_NAME] [SNAPSHOT_NAME]"
    echo ""
    echo "Modes:"
    echo "  dev    - Development mode (with window, for debugging)"
    echo "  ci     - CI mode (headless, optimized for speed)"
    echo "  cold   - Cold boot (no snapshot, for troubleshooting)"
    echo ""
    echo "Examples:"
    echo "  $0 dev                    # Start in dev mode"
    echo "  $0 ci E2E_Optimized       # Start in CI mode with specific AVD"
    echo "  $0 cold Pixel_API_34      # Cold boot for existing AVD"
    exit 1
}

# ヘルプ表示
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

# AVDの存在確認
if [ ! -d "$HOME/.android/avd/${AVD_NAME}.avd" ]; then
    echo "Error: AVD '$AVD_NAME' not found."
    echo ""
    echo "Available AVDs:"
    "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" list avd -c 2>/dev/null || echo "  (none)"
    echo ""
    echo "Create E2E optimized AVD: ./scripts/setup_e2e_emulator.sh"
    exit 1
fi

echo "=== Starting Android Emulator ==="
echo "Mode: $MODE"
echo "AVD: $AVD_NAME"
echo "Snapshot: $SNAPSHOT_NAME"
echo "================================="

# 既存エミュレーター確認
if adb devices 2>/dev/null | grep -q "emulator-"; then
    echo "Note: Emulator already running."
    echo "Waiting for device to be ready..."
    adb wait-for-device
    echo "Emulator ready!"
    exit 0
fi

# モード別起動
case "$MODE" in
    ci)
        echo "Starting in CI mode (headless)..."
        "$EMULATOR_PATH" @"$AVD_NAME" \
            -no-window \
            -no-audio \
            -no-boot-anim \
            -no-skin \
            -cores 2 \
            -snapshot "$SNAPSHOT_NAME" \
            -no-snapshot-save \
            -gpu swiftshader_indirect \
            &
        ;;
    dev)
        echo "Starting in development mode..."
        "$EMULATOR_PATH" @"$AVD_NAME" \
            -no-audio \
            -no-boot-anim \
            -snapshot "$SNAPSHOT_NAME" \
            -gpu auto \
            &
        ;;
    cold)
        echo "Starting with cold boot..."
        "$EMULATOR_PATH" @"$AVD_NAME" \
            -no-audio \
            -no-snapshot-load \
            -gpu auto \
            &
        ;;
    *)
        echo "Error: Unknown mode '$MODE'"
        usage
        ;;
esac

echo "Waiting for device..."
adb wait-for-device

echo "Waiting for boot completion (timeout: ${BOOT_TIMEOUT}s)..."
ELAPSED=0
while [ -z "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" ]; do
    sleep 1
    ELAPSED=$((ELAPSED + 1))
    if [ $ELAPSED -ge $BOOT_TIMEOUT ]; then
        echo "Error: Boot timeout after ${BOOT_TIMEOUT}s"
        adb emu kill 2>/dev/null || true
        exit 1
    fi
done

echo ""
echo "=== Emulator Ready! ==="
echo "Device: $(adb shell getprop ro.product.model | tr -d '\r')"
echo "Android: $(adb shell getprop ro.build.version.release | tr -d '\r')"
