#!/bin/bash
# Validate manifest file for Roku channel

set -e

MANIFEST="manifest"

echo "Validating manifest..."

if [ ! -f "$MANIFEST" ]; then
    echo "❌ manifest file not found"
    exit 1
fi

# Check required fields
required_fields=(
    "title"
    "major_version"
    "minor_version"
    "build_version"
    "mm_icon_focus_hd"
    "mm_icon_focus_fhd"
    "splash_screen_hd"
    "splash_screen_fhd"
)

errors=0

for field in "${required_fields[@]}"; do
    if ! grep -q "^${field}=" "$MANIFEST"; then
        echo "❌ Missing required field: $field"
        ((errors++))
    fi
done

# Check version format
version_regex="^[0-9]+\$"
major=$(grep "^major_version=" "$MANIFEST" | cut -d= -f2)
minor=$(grep "^minor_version=" "$MANIFEST" | cut -d= -f2)
build=$(grep "^build_version=" "$MANIFEST" | cut -d= -f2)

if ! [[ $major =~ $version_regex ]]; then
    echo "❌ major_version must be numeric"
    ((errors++))
fi

if ! [[ $minor =~ $version_regex ]]; then
    echo "❌ minor_version must be numeric"
    ((errors++))
fi

if ! [[ $build =~ $version_regex ]]; then
    echo "❌ build_version must be numeric"
    ((errors++))
fi

# Check title length
title=$(grep "^title=" "$MANIFEST" | cut -d= -f2)
if [ ${#title} -gt 40 ]; then
    echo "⚠️  Warning: title exceeds 40 characters (${#title} chars)"
fi

if [ $errors -eq 0 ]; then
    echo "✓ Manifest validation passed"
    echo ""
    echo "Channel: $title"
    echo "Version: $major.$minor.$build"
else
    echo ""
    echo "❌ Manifest validation failed with $errors error(s)"
    exit 1
fi
