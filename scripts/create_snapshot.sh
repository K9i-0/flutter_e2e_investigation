#!/usr/bin/env bash
# E2E用スナップショット作成スクリプト
# 起動済み状態を保存し、次回からの高速起動を実現

set -e

# ANDROID_HOME チェック
if [ -z "$ANDROID_HOME" ]; then
    echo "Error: ANDROID_HOME is not set."
    echo "Please set ANDROID_HOME to your Android SDK location."
    exit 1
fi

AVD_NAME="${1:-E2E_Optimized}"
SNAPSHOT_NAME="${2:-e2e_ready}"
EMULATOR_PATH="$ANDROID_HOME/emulator/emulator"
BOOT_TIMEOUT=120

echo "=== Creating E2E Snapshot ==="
echo "AVD: $AVD_NAME"
echo "Snapshot: $SNAPSHOT_NAME"
echo "============================="

# AVDの存在確認
if [ ! -d "$HOME/.android/avd/${AVD_NAME}.avd" ]; then
    echo "Error: AVD '$AVD_NAME' not found."
    echo "Create it first: ./scripts/setup_e2e_emulator.sh $AVD_NAME"
    exit 1
fi

# 既存のエミュレーター確認
if adb devices 2>/dev/null | grep -q "emulator-"; then
    echo "Warning: Emulator already running. Please close it first."
    echo "Run: adb emu kill"
    exit 1
fi

echo "[1/5] Starting emulator (cold boot)..."
"$EMULATOR_PATH" @"$AVD_NAME" \
    -no-audio \
    -no-snapshot-load \
    -gpu auto \
    &

EMULATOR_PID=$!

echo "[2/5] Waiting for device..."
adb wait-for-device

echo "[3/5] Waiting for boot completion (timeout: ${BOOT_TIMEOUT}s)..."
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
echo "Boot completed!"

echo "[4/5] Waiting for UI to stabilize..."
sleep 5

# ホーム画面に移動（安定した状態を確保）
adb shell input keyevent KEYCODE_HOME

sleep 2

echo "[5/5] Saving snapshot: $SNAPSHOT_NAME"
adb emu avd snapshot save "$SNAPSHOT_NAME"

echo ""
echo "Snapshot created successfully!"
echo ""

# エミュレーター終了
echo "Shutting down emulator..."
adb emu kill

# プロセス終了待機
wait $EMULATOR_PID 2>/dev/null || true

echo ""
echo "=== Snapshot Ready ==="
echo "Next time, start with: ./scripts/start_emulator.sh dev $AVD_NAME"
echo "Expected boot time: ~5-10 seconds (vs ~60 seconds cold boot)"
