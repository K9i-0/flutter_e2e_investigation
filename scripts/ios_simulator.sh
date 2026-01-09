#!/usr/bin/env bash
# iOS Simulator 管理スクリプト
# E2Eテスト用に最適化されたシミュレーター起動・管理

set -e

ACTION="${1:-start}"
DEVICE="${2:-}"

# デフォルトデバイス（軽量なものを優先）
DEFAULT_DEVICES=(
    "iPhone 16e"        # 最も軽量
    "iPhone 17"         # 標準
    "iPhone 17 Pro"     # 高解像度
)

usage() {
    echo "Usage: $0 [ACTION] [DEVICE]"
    echo ""
    echo "Actions:"
    echo "  start   - Start simulator (default)"
    echo "  stop    - Stop all simulators"
    echo "  list    - List available devices"
    echo "  status  - Show running simulators"
    echo "  reset   - Reset simulator (erase all content)"
    echo ""
    echo "Examples:"
    echo "  $0 start                    # Start default device"
    echo "  $0 start 'iPhone 17 Pro'    # Start specific device"
    echo "  $0 list                     # Show available devices"
    echo "  $0 stop                     # Stop all simulators"
    exit 1
}

# ヘルプ表示
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

# デバイス検索（利用可能なデバイスから選択）
find_device() {
    local target="$1"

    if [ -n "$target" ]; then
        # 指定されたデバイスを検索
        xcrun simctl list devices available | grep -E "^\s+$target" | head -1 | grep -oE '\([A-F0-9-]+\)' | tr -d '()' || true
    else
        # デフォルトデバイスを順に検索
        for device in "${DEFAULT_DEVICES[@]}"; do
            local udid
            udid=$(xcrun simctl list devices available | grep -E "^\s+$device" | head -1 | grep -oE '\([A-F0-9-]+\)' | tr -d '()' || true)
            if [ -n "$udid" ]; then
                echo "$udid"
                return
            fi
        done
    fi
}

# ステータスバー固定（テスト安定化）
stabilize_status_bar() {
    local udid="$1"
    xcrun simctl status_bar "$udid" override \
        --time "9:41" \
        --batteryLevel 100 \
        --batteryState charged \
        --cellularMode active \
        --cellularBars 4 \
        --wifiBars 3 \
        --operatorName "E2E Test" \
        2>/dev/null || true
}

case "$ACTION" in
    start)
        echo "=== Starting iOS Simulator ==="

        # デバイスUDID取得
        UDID=$(find_device "$DEVICE")

        if [ -z "$UDID" ]; then
            echo "Error: Device not found."
            echo ""
            echo "Available devices:"
            xcrun simctl list devices available | grep -E "iPhone|iPad" | head -10
            exit 1
        fi

        # デバイス名取得
        DEVICE_NAME=$(xcrun simctl list devices | grep "$UDID" | sed 's/(.*//' | xargs)
        echo "Device: $DEVICE_NAME"
        echo "UDID: $UDID"

        # 既に起動中かチェック
        if xcrun simctl list devices | grep "$UDID" | grep -q "(Booted)"; then
            echo "Simulator already running."
        else
            echo "Booting simulator..."
            xcrun simctl boot "$UDID"
        fi

        # ステータスバー固定
        echo "Stabilizing status bar..."
        stabilize_status_bar "$UDID"

        # Simulator.app を開く（GUIを表示）
        open -a Simulator

        echo ""
        echo "=== Simulator Ready! ==="
        echo "Device: $DEVICE_NAME"
        ;;

    stop)
        echo "Stopping all simulators..."
        xcrun simctl shutdown all
        echo "All simulators stopped."
        ;;

    list)
        echo "=== Available iOS Devices ==="
        echo ""
        echo "iPhones:"
        xcrun simctl list devices available | grep -E "iPhone" | head -15
        echo ""
        echo "iPads:"
        xcrun simctl list devices available | grep -E "iPad" | head -5
        ;;

    status)
        echo "=== Running Simulators ==="
        BOOTED=$(xcrun simctl list devices | grep "(Booted)" || true)
        if [ -z "$BOOTED" ]; then
            echo "No simulators running."
        else
            echo "$BOOTED"
        fi
        ;;

    reset)
        if [ -z "$DEVICE" ]; then
            echo "Error: Device name required for reset."
            echo "Usage: $0 reset 'iPhone 17 Pro'"
            exit 1
        fi

        UDID=$(find_device "$DEVICE")
        if [ -z "$UDID" ]; then
            echo "Error: Device '$DEVICE' not found."
            exit 1
        fi

        echo "Resetting device: $DEVICE"
        xcrun simctl erase "$UDID"
        echo "Device reset complete."
        ;;

    *)
        echo "Error: Unknown action '$ACTION'"
        usage
        ;;
esac
