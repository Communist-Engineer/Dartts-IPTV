#!/bin/bash
# Integration test script for Dartt's IPTV
# Tests deep linking via Roku ECP (External Control Protocol)

set -e

ROKU_IP="${ROKU_IP:-192.168.1.100}"
APP_ID="${APP_ID:-dev}"

echo "======================================"
echo "Dartt's IPTV Integration Tests"
echo "======================================"
echo "Target Roku: $ROKU_IP"
echo "App ID: $APP_ID"
echo ""

# Check if Roku is reachable
echo "Checking Roku connectivity..."
if ! curl -s "http://$ROKU_IP:8060" > /dev/null; then
    echo "❌ Cannot reach Roku at $ROKU_IP"
    echo "Set ROKU_IP environment variable to your Roku's IP address"
    exit 1
fi

echo "✓ Roku is reachable"
echo ""

# Test 1: Launch app
echo "Test 1: Launching app..."
curl -d '' "http://$ROKU_IP:8060/launch/$APP_ID" > /dev/null 2>&1
sleep 3
echo "✓ App launched"
echo ""

# Test 2: Deep link to content
echo "Test 2: Testing deep link..."
curl -d '' "http://$ROKU_IP:8060/launch/$APP_ID?contentId=sample_test1&mediaType=live" > /dev/null 2>&1
sleep 2
echo "✓ Deep link sent"
echo ""

# Test 3: Send key commands
echo "Test 3: Testing navigation..."
curl -d '' "http://$ROKU_IP:8060/keypress/Home" > /dev/null 2>&1
sleep 1
echo "✓ Navigation test complete"
echo ""

echo "======================================"
echo "Integration tests complete!"
echo "======================================"
echo ""
echo "Manual verification checklist:"
echo "  [ ] App launches without crashes"
echo "  [ ] Deep link navigates to correct content"
echo "  [ ] Video playback starts"
echo "  [ ] Back button returns to home"
echo "  [ ] First-run dialog appears (first launch only)"
echo ""
