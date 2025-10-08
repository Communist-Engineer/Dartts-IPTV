#!/bin/bash
# Sideload script for Dartt's IPTV Roku channel

set -e

ROKU_IP=$1
ROKU_USER=$2
ROKU_PASS=$3
BUILD_DIR=$4

if [ -z "$ROKU_IP" ] || [ -z "$BUILD_DIR" ]; then
    echo "Usage: sideload.sh <roku_ip> <user> <password> <build_dir>"
    exit 1
fi

echo "Sideloading to Roku at $ROKU_IP..."

# Create temporary zip
TMP_ZIP="/tmp/dartts_iptv_sideload_$$.zip"
cd "$BUILD_DIR" && zip -r "$TMP_ZIP" . -q

# Delete existing dev channel
echo "Removing existing dev channel..."
curl -s -S --digest -u "$ROKU_USER:$ROKU_PASS" \
    -F "mysubmit=Delete" \
    -F "archive=" \
    "http://$ROKU_IP/plugin_install" > /dev/null

sleep 2

# Install new channel
echo "Installing channel..."
RESPONSE=$(curl -s -S --digest -u "$ROKU_USER:$ROKU_PASS" \
    -F "mysubmit=Install" \
    -F "archive=@$TMP_ZIP" \
    "http://$ROKU_IP/plugin_install")

# Clean up
rm -f "$TMP_ZIP"

# Check for success
if echo "$RESPONSE" | grep -q "Install Success"; then
    echo "✓ Channel installed successfully"
    
    # Launch the channel
    echo "Launching channel..."
    curl -d '' "http://$ROKU_IP:8060/launch/dev" > /dev/null 2>&1
    
    echo ""
    echo "Channel is running on your Roku!"
    echo "Debug console: telnet $ROKU_IP 8085"
elif echo "$RESPONSE" | grep -q "Identical to previous version"; then
    echo "✓ Channel already up to date"
else
    echo "❌ Installation failed"
    echo ""
    echo "Response from Roku:"
    echo "$RESPONSE"
    echo ""
    echo "Common issues:"
    echo "  - Wrong password (check ROKU_PASS environment variable)"
    echo "  - Developer mode not enabled on Roku"
    echo "  - Roku IP address incorrect"
    echo ""
    exit 1
fi
