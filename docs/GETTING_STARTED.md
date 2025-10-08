# Getting Started with Dartt's IPTV

This guide walks you thro1. **Clone the Repository**
   ```bash
   git clone https://github.com/Communist-Engineer/Dartts-IPTV.git
   cd Dartts-IPTVsetting up and using Dartt's IPTV on your Roku device.

---

## Prerequisites

- **Roku Device**: Any current-generation Roku (HD, 4K, Stick, TV, etc.)
- **Network**: Roku and computer on the same local network
- **Developer Mode**: Enabled on your Roku (see below)

---

## Step 1: Enable Developer Mode

1. On your Roku, press the **Home** button on your remote
2. Enter this button sequence:
   - **Home** (3 times)
   - **Up** (2 times)
   - **Right**
   - **Left**
   - **Right**
   - **Left**
   - **Right**
3. A **Developer Settings** screen will appear
4. Choose **Enable Installer**
5. Set a password (default: `rokudev`)
6. **Restart** your Roku

---

## Step 2: Find Your Roku's IP Address

### Option A: On Roku UI
1. Go to **Settings** → **Network** → **About**
2. Note the **IP Address**

### Option B: From Developer Settings
1. Return to Developer Settings (same button sequence)
2. IP address is displayed at the top

Example: `192.168.1.100`

---

## Step 3: Install Dartt's IPTV

### Option 1: Download Pre-built Package

1. Download the latest `DarttsIPTV.zip` from [Releases](https://github.com/Communist-Engineer/Dartts-IPTV/releases)
2. Open a web browser and navigate to:
   ```
   http://YOUR_ROKU_IP
   ```
3. Log in with username `rokudev` and your password
4. Under **Upload Package**, choose the ZIP file
5. Click **Install**
6. Wait for installation to complete

### Option B: Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/darttdev/Dartts-IPTV.git
   cd Dartts-IPTV
   ```

2. (Optional) Save your Roku password:
   ```bash
   echo "your_password" > .roku_password
   ```

3. Build and sideload:
   ```bash
   make dev ROKU_IP=192.168.1.100
   ```

---

## Step 4: First Launch

1. On your Roku, navigate to **Home** → **My Channels**
2. Find and launch **Dartt's IPTV** (it will have a "dev" icon)
3. **Legal Notice** will appear - read and accept
4. You'll see the home screen

---

## Step 5: Add a Playlist

### From a URL

1. Press **Options** or navigate to **Settings**
2. Select **Add Playlist**
3. Enter your M3U/M3U8 URL:
   ```
   http://example.com/playlist.m3u8
   ```
4. Press **OK** to save
5. The app will fetch and parse the playlist

### Using the Sample Playlist

For testing, use the included sample:

```
file://pkg:/samples/sample.m3u8
```

Or serve it locally:

```bash
# In the project directory
python3 -m http.server 8000
```

Then use: `http://YOUR_COMPUTER_IP:8000/samples/sample.m3u8`

---

## Step 6: Add EPG (Optional)

1. Go to **Settings** → **EPG Settings**
2. Enter your XMLTV URL:
   ```
   http://example.com/epg.xml
   ```
3. Press **OK**
4. The EPG will load in the background

For testing, use: `file://pkg:/samples/sample.xmltv`

---

## Step 7: Browse and Play

### Browse Channels

- **All Channels** - Complete list
- **Groups** - Organized by `group-title` from M3U
- **Favorites** - Mark channels with a star (future)
- **Recents** - Last played channels

### Play a Channel

1. Navigate to a channel and press **OK**
2. Stream will load and play
3. Press **Info** to show/hide overlay
4. Press **Back** to return to list

### Guide (with EPG)

1. Select **Guide** from home
2. View now/next programs for each channel
3. Press **OK** on a program to start playback

---

## Step 8: Debug Console (Optional)

Monitor logs and debug information:

```bash
telnet YOUR_ROKU_IP 8085
```

You'll see:
- App startup logs
- Parsing progress
- Playback events
- Errors and warnings

Press **Ctrl+]** then type `quit` to exit.

---

## Troubleshooting

### "Cannot reach Roku" during sideload

- Verify Roku IP address
- Ensure both devices are on same network
- Check firewall settings
- Try pinging: `ping 192.168.1.100`

### "Installation failed"

- Verify Developer Mode is enabled
- Check password is correct
- Try deleting existing dev channel first:
  ```bash
  curl -u rokudev:PASSWORD -F "mysubmit=Delete" http://ROKU_IP/plugin_install
  ```

### "Playlist won't load"

- Verify URL is accessible from Roku's network
- Check for HTTPS/certificate issues
- Try the sample playlist first
- Check telnet logs for error messages

### "No channels appear"

- Verify M3U format (must start with `#EXTM3U`)
- Check for parsing errors in telnet logs
- Try a known-good playlist

### "Playback fails"

- Ensure stream is HLS (`.m3u8`)
- Verify stream is not DRM-protected
- Check stream URL is accessible
- Test stream in VLC or another player first

---

## Next Steps

- [Playlist Configuration](PLAYLISTS.md) - M3U and XMLTV details
- [Deep Linking](DEEP_LINKING.md) - Launch channels programmatically
- [Contributing](../CONTRIBUTING.md) - Help improve the app

---

## Uninstalling

### Remove Dev Channel

1. On Roku: **Settings** → **System** → **Developer options** → **Delete dev channel**

OR via web:

```bash
curl -u rokudev:PASSWORD -F "mysubmit=Delete" http://ROKU_IP/plugin_install
```

### Disable Developer Mode

1. Access Developer Settings (same button sequence)
2. Choose **Disable Installer**

---

**Enjoy streaming! 📺**
