#!/usr/bin/env bash
# debug_check.sh — Verify the Flutter debug environment is ready.

set -e

echo "=== Flutter Doctor ==="
flutter doctor

echo ""
echo "=== Flutter Pub Get ==="
flutter pub get

echo ""
echo "=== Flutter Analyze ==="
flutter analyze

echo ""
echo "✅ Debug environment ready"
