#!/usr/bin/env bash
# E2Eテスト環境 統合起動スクリプト
# iOS / Android / 両方 を簡単に起動

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLATFORM="${1:-ios}"
MODE="${2:-dev}"

usage() {
    echo "Usage: $0 [PLATFORM] [MODE]"
    echo ""
    echo "Platforms:"
    echo "  ios     - iOS Simulator only (default)"
    echo "  android - Android Emulator only"
    echo "  both    - Both platforms"
    echo ""
    echo "Modes (Android only):"
    echo "  dev     - Development mode (with window)"
    echo "  ci      - CI mode (headless, fast)"
    echo ""
    echo "Examples:"
    echo "  $0 ios              # Start iOS simulator"
    echo "  $0 android dev      # Start Android in dev mode"
    echo "  $0 android ci       # Start Android headless"
    echo "  $0 both             # Start both platforms"
    exit 1
}

# ヘルプ表示
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

echo "============================================"
echo "       E2E Test Environment Setup"
echo "============================================"
echo "Platform: $PLATFORM"
echo "Mode: $MODE"
echo "============================================"
echo ""

start_ios() {
    echo ">>> Starting iOS Simulator..."
    "$SCRIPT_DIR/ios_simulator.sh" start
    echo ""
}

start_android() {
    local mode="$1"
    echo ">>> Starting Android Emulator ($mode mode)..."
    "$SCRIPT_DIR/start_emulator.sh" "$mode"
    echo ""
}

case "$PLATFORM" in
    ios)
        start_ios
        ;;
    android)
        start_android "$MODE"
        ;;
    both)
        # 並列起動
        start_android "$MODE" &
        ANDROID_PID=$!
        start_ios

        # Android起動完了待機
        wait $ANDROID_PID 2>/dev/null || true
        ;;
    *)
        echo "Error: Unknown platform '$PLATFORM'"
        usage
        ;;
esac

echo "============================================"
echo "       Environment Ready!"
echo "============================================"
echo ""
echo "Next steps:"
echo "  - Run Flutter app:  flutter run"
echo "  - Run E2E tests:    maestro test .maestro/"
echo "  - Use Dart MCP:     launch_app, hot_reload"
echo "  - Use Maestro MCP:  tap_on, input_text, take_screenshot"
echo ""
