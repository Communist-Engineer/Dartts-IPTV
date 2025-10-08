# Dartt's IPTV

**A FREE and OPEN-SOURCE Roku channel for streaming user-supplied IPTV playlists.**

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Roku](https://img.shields.io/badge/Platform-Roku-purple.svg)
![Version](https://img.shields.io/badge/Version-1.0.0-green.svg)

---

## ⚠️ Legal Notice

**Dartt's IPTV does NOT provide any video streams, channels, or copyrighted content.**

This application is a **player only**. You must supply your own M3U/M3U8 playlists and XMLTV EPG data. Ensure you have the legal rights to access and view any streams you configure. The developers assume no responsibility for how you use this software.

---

## Features

✅ **M3U/M3U8 Playlist Support** - Load IPTV playlists from URLs or local files  
✅ **XMLTV EPG Integration** - Display now/next program guides with metadata  
✅ **HLS Streaming** - Play HTTP Live Streaming (HLS) video  
✅ **Group Organization** - Browse channels by groups, favorites, recents  
✅ **Deep Linking** - Launch directly to specific channels via ECP  
✅ **Closed Captions** - Support for WebVTT subtitles in HLS streams  
✅ **Persistent Settings** - Save playlists, favorites, and preferences  
✅ **Fast Parsing** - Efficient background tasks with caching  
✅ **Network Resilience** - Automatic retries and error handling  

---

## Quick Start

### 1. Enable Developer Mode on Your Roku

1. Press **Home** 3x, **Up** 2x, **Right**, **Left**, **Right**, **Left**, **Right**
2. Enable **Developer Mode** and set a password
3. Note your Roku's IP address

### 2. Clone and Build

```bash
git clone https://github.com/darttdev/Dartts-IPTV.git
cd Dartts-IPTV
```

### 3. Configure Your Roku

Create a `.roku_password` file (optional):

```bash
echo "your_dev_password" > .roku_password
```

### 4. Sideload to Your Roku

```bash
make dev ROKU_IP=192.168.1.100
```

This will build and install the channel on your Roku device.

---

## Usage

### Adding a Playlist

1. Launch **Dartt's IPTV** on your Roku
2. On first run, accept the legal notice
3. Navigate to **Settings** → **Add Playlist**
4. Enter your M3U/M3U8 playlist URL
5. (Optional) Add an XMLTV EPG URL for program guides

### Playing Channels

- Browse by **All Channels**, **Groups**, **Favorites**, or **Recents**
- Select a channel to start playback
- Press **←/→** to zap between channels (when implemented)
- Press **Info** to toggle overlay information
- Press **Back** to return to the channel list

### Deep Linking

Launch a specific channel from command line or automation:

```bash
curl -d '' "http://ROKU_IP:8060/launch/dev?contentId=sample_test1&mediaType=live"
```

---

## Development

### Prerequisites

- Roku device with Developer Mode enabled
- macOS, Linux, or Windows with bash/WSL
- `curl` and `zip` utilities
- (Optional) VS Code with BrightScript extension

### Project Structure

```
Dartts_IPTV/
├── manifest                 # Channel manifest (required)
├── source/
│   ├── main.brs            # Entry point
│   ├── AppScene.xml/brs    # Root scene
│   ├── components/         # SceneGraph components
│   ├── services/           # Parsers, network, cache
│   ├── tasks/              # Background tasks
│   ├── models/             # Data models
│   └── utils/              # Logging, helpers
├── samples/                # Sample M3U, XMLTV, catalog
├── tests/                  # Unit and integration tests
├── scripts/                # Build and sideload scripts
├── docs/                   # Documentation
└── Makefile                # Build automation
```

### Build Commands

```bash
make help        # Show all available commands
make build       # Build the channel package
make sideload    # Install to Roku device
make dev         # Build + sideload (quick loop)
make test        # Run unit tests
make clean       # Remove build artifacts
make package     # Create distributable ZIP
```

### Testing

#### Unit Tests
```bash
make test
```

#### Integration Tests
```bash
make integration-test ROKU_IP=192.168.1.100
```

#### Manual Testing Checklist

- [ ] App launches without crashes
- [ ] First-run legal notice displays
- [ ] Add playlist from URL
- [ ] Browse channels by group
- [ ] Play HLS stream
- [ ] Captions toggle (if stream has CC)
- [ ] Deep link launches correct channel
- [ ] Back button returns to home
- [ ] Settings persist after relaunch

---

## Configuration

### Playlists

Add M3U/M3U8 URLs in **Settings → Manage Playlists**.

**Supported tags:**
- `#EXTINF` - Channel name, duration
- `tvg-id` - EPG mapping ID
- `tvg-name` - Display name
- `tvg-logo` - Channel logo URL
- `group-title` - Group/category
- `#EXTGRP` - Group override

### XMLTV EPG

Add XMLTV URL in **Settings → EPG Settings**.

Dartt's IPTV will:
- Parse channel definitions
- Index programs by channel ID
- Compute "now playing" and "next" based on current time
- Display program metadata (title, description, season/episode)

### Advanced Settings

- **Time Offset** - Adjust EPG timezone (minutes)
- **User Agent** - Custom HTTP user agent string
- **Timeout** - Network request timeout (ms)
- **Parental Controls** - PIN-protect specific groups (future)

---

## Certification

**✅ Dartt's IPTV is now certification-ready!**

All required images are included in the package:
- ✅ Focus icons (HD and FHD)
- ✅ Side icons (HD and FHD)  
- ✅ Splash screens (HD and FHD)

To submit Dartt's IPTV to the Roku Channel Store:

1. **~~Add Required Images~~** ✅ COMPLETE
   - All images are now included in the package
   - See `IMAGE_VERIFICATION.md` for details

2. **Complete Manifest** ✅ COMPLETE
   - Set final `version`, `subtitle`, `support_url`
   - Add `splash_color` matching your branding

3. **Deep Link Testing**
   - Test with Roku's Deep Linking Tester
   - Verify `contentId` and `mediaType` handling
   - Provide sample `deep_link_catalog.json`

4. **Content Policy**
   - Ensure all sample streams are legal and public domain
   - Remove any copyrighted test content
   - Verify first-run legal notice is clear

5. **QA Checklist**
   - No crashes on launch
   - Handles network failures gracefully
   - Accessible UI (focus, readable text)
   - Works on HD (720p) and FHD (1080p) devices

See `docs/CERTIFICATION.md` for detailed checklist.

---

## Documentation

- [Getting Started](docs/GETTING_STARTED.md) - Setup and installation
- [Playlist Configuration](docs/PLAYLISTS.md) - M3U and XMLTV setup
- [Deep Linking](docs/DEEP_LINKING.md) - ECP integration guide
- [Certification Prep](docs/CERTIFICATION.md) - Roku store submission
- [Contributing](CONTRIBUTING.md) - How to contribute
- [Security Policy](SECURITY.md) - Reporting vulnerabilities

---

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for:

- Code style guidelines
- Commit message conventions
- Pull request process
- Testing requirements

---

## License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

---

## Support

- **Issues**: [GitHub Issues](https://github.com/darttdev/Dartts-IPTV/issues)
- **Discussions**: [GitHub Discussions](https://github.com/darttdev/Dartts-IPTV/discussions)
- **Documentation**: [docs/](docs/)

---

## Acknowledgments

- Built with Roku SceneGraph and BrightScript
- Inspired by the open-source IPTV community
- Sample streams courtesy of public test HLS sources

---

## Disclaimer

**This software is provided "as is" without warranty of any kind.**

Dartt's IPTV is a video player application. It does not host, provide, or distribute any video content. Users are solely responsible for ensuring they have the legal right to access any streams they configure. The developers and contributors assume no liability for misuse of this software.

---

**Enjoy your IPTV streams on Roku! 📺**
