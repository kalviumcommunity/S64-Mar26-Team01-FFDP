#!/bin/bash
# Script to replace all withOpacity with withValues(alpha:)

find lib -name "*.dart" -type f -exec sed -i '' 's/\.withOpacity(\([0-9.]*\))/\.withValues(alpha: \1)/g' {} \;

echo "✅ Replaced all withOpacity with withValues(alpha:)"
