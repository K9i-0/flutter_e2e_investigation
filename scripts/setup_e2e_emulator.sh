#!/usr/bin/env bash
# E2E専用Android AVD作成スクリプト
# 軽量設定で高速起動・低リソース消費を実現

set -e

# ANDROID_HOME チェック
if [ -z "$ANDROID_HOME" ]; then
    echo "Error: ANDROID_HOME is not set."
    echo "Please set ANDROID_HOME to your Android SDK location."
    exit 1
fi

AVD_NAME="${1:-E2E_Optimized}"
API_LEVEL="${2:-34}"
DEVICE="pixel"
SYSTEM_IMAGE="system-images;android-${API_LEVEL};google_apis;arm64-v8a"

echo "=== E2E Optimized AVD Setup ==="
echo "AVD Name: $AVD_NAME"
echo "API Level: $API_LEVEL"
echo "Device: $DEVICE"
echo "=============================="

# システムイメージの確認・インストール
echo "[1/4] Checking system image..."
if ! "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --list_installed 2>/dev/null | grep -q "$SYSTEM_IMAGE"; then
    echo "Installing system image: $SYSTEM_IMAGE"
    "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "$SYSTEM_IMAGE"
fi

# 既存AVDの削除（存在する場合）
echo "[2/4] Creating AVD..."
if [ -d "$HOME/.android/avd/${AVD_NAME}.avd" ]; then
    echo "Removing existing AVD: $AVD_NAME"
    "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" delete avd --name "$AVD_NAME" 2>/dev/null || true
fi

# AVD作成
"$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" create avd \
    --name "$AVD_NAME" \
    --package "$SYSTEM_IMAGE" \
    --device "$DEVICE" \
    --force

# 設定ファイルのパス
CONFIG_FILE="$HOME/.android/avd/${AVD_NAME}.avd/config.ini"

echo "[3/4] Optimizing AVD configuration..."

# E2E用に最適化された設定を追加
cat >> "$CONFIG_FILE" << 'EOF'

# === E2E Optimization Settings ===

# 不要なセンサー・機能を無効化
hw.audioInput = no
hw.audioOutput = no
hw.camera.back = none
hw.camera.front = none
hw.gps = no
hw.sensors.humidity = no
hw.sensors.proximity = no
hw.sensors.temperature = no
hw.sensors.heart_rate = no
hw.sensors.wrist_tilt = no
hw.sensors.rgbclight = no

# FastBoot有効化
fastboot.forceFastBoot = yes
firstboot.bootFromLocalSnapshot = yes
firstboot.saveToLocalSnapshot = yes

# パフォーマンス設定
hw.gpu.mode = auto
hw.ramSize = 2G
vm.heapSize = 256M
EOF

echo "[4/4] AVD created successfully!"
echo ""
echo "Next steps:"
echo "  1. Create snapshot: ./scripts/create_snapshot.sh $AVD_NAME"
echo "  2. Start emulator:  ./scripts/start_emulator.sh dev $AVD_NAME"
echo ""
echo "AVD location: $HOME/.android/avd/${AVD_NAME}.avd"
