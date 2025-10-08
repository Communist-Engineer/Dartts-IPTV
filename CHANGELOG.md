# Changelog

All notable changes to Dartt's IPTV will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2025-10-07

### Added
- Initial release of Dartt's IPTV
- M3U/M3U8 playlist parser with support for:
  - `#EXTINF` directive
  - `tvg-id`, `tvg-name`, `tvg-logo`, `group-title` attributes
  - `#EXTGRP` directive
  - Unicode channel names
- XMLTV EPG parser with:
  - Channel definitions
  - Program schedules
  - Now/Next timeline computation
  - Season/episode metadata
- HLS video playback via Roku Video node
- SceneGraph UI components:
  - Home screen with first-run legal notice
  - Channel list view
  - Group browser
  - Video player with overlay
  - Settings modal
  - EPG guide view
- Deep linking support:
  - Launch via `contentId` and `mediaType` parameters
  - Sample catalog for testing
- Persistent settings via registry:
  - Playlists
  - Favorites
  - Recents
  - User preferences
- Cache service for parsed data
- Network service with retry logic and backoff
- Background tasks for asynchronous loading
- Logging utilities with timestamp
- Build and sideload tooling:
  - Makefile with dev loop
  - Sideload script
  - Manifest validation
- Unit tests for parsers
- Integration test scripts for deep linking
- Comprehensive documentation:
  - README with quick start
  - Getting Started guide
  - Certification checklist
  - Contributing guidelines
  - Security policy
- CI/CD pipeline via GitHub Actions:
  - Manifest validation
  - Build and test
  - Artifact creation
  - Optional sideload to Roku
- Sample assets:
  - `sample.m3u8` - Test playlist
  - `sample.xmltv` - Test EPG
  - `deep_link_catalog.json` - Deep link catalog
- MIT license
- Code of Conduct

### Security
- Legal notice on first run
- No bundled streams or copyrighted content
- User-supplied content only
- HTTPS recommended for all URLs
- Input validation for M3U/XMLTV parsers

---

## [Unreleased]

### Planned Features
- Channel search/filter
- Favorites management
- Recents with resume positions
- Parental controls with PIN
- Channel zapping (left/right in player)
- Grid view for channels
- EPG timeline view
- Multiple playlist merge strategies
- Advanced network settings
- Image placeholders for channels without logos
- Accessibility improvements
- Localization (Spanish, French, etc.)

---

[1.0.0]: https://github.com/darttdev/Dartts-IPTV/releases/tag/v1.0.0
