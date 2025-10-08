# Roku Channel Certification Checklist

This document outlines the requirements and steps to submit Dartt's IPTV to the Roku Channel Store.

---

## Prerequisites

- [ ] Roku Developer Account (free at [developer.roku.com](https://developer.roku.com))
- [ ] Channel fully tested and working
- [ ] All required assets prepared
- [ ] Legal compliance verified

---

## 1. Manifest Requirements

Update `manifest` file with production values:

- [ ] **title** - Max 40 characters, must match Channel Store listing
- [ ] **subtitle** - Short tagline (optional, max 80 chars)
- [ ] **version** - Semantic version (e.g., `1.0.0`)
- [ ] **major_version**, **minor_version**, **build_version** - Must match `version`
- [ ] **mm_icon_focus_hd** - 290x218 PNG (required)
- [ ] **mm_icon_focus_fhd** - 336x210 PNG (required)
- [ ] **mm_icon_side_hd** - 108x69 PNG (required)
- [ ] **mm_icon_side_fhd** - 180x108 PNG (required)
- [ ] **splash_screen_hd** - 1280x720 PNG (required)
- [ ] **splash_screen_fhd** - 1920x1080 PNG (required)
- [ ] **splash_color** - Hex color matching splash background
- [ ] **support_url** - Valid URL for user support
- [ ] **ui_resolutions** - `hd,fhd` (recommended)

Validate manifest:

```bash
make validate
```

---

## 2. Channel Images

Create high-quality images (PNG format):

### Focus Icons (highlighted in UI)
- **icon_focus_hd.png** - 290×218 pixels
- **icon_focus_fhd.png** - 336×210 pixels

### Side Icons (unhighlighted in UI)
- **icon_side_hd.png** - 108×69 pixels
- **icon_side_fhd.png** - 180×108 pixels

### Splash Screens (loading screen)
- **splash_hd.png** - 1280×720 pixels
- **splash_fhd.png** - 1920×1080 pixels

**Guidelines:**
- Use transparent backgrounds for icons
- Include app branding/logo
- Avoid text smaller than 18pt
- Follow [Roku Design Guidelines](https://developer.roku.com/design/design-guidelines.md)

Place images in `source/images/` directory.

---

## 3. Deep Linking

Roku requires deep linking support for certification.

- [ ] Implement `contentId` handling in `main.brs`
- [ ] Support `mediaType` parameter
- [ ] Provide sample content in `deep_link_catalog.json`
- [ ] Test with Roku's Deep Linking Tester

### Test Deep Linking

```bash
curl -d '' "http://ROKU_IP:8060/launch/dev?contentId=sample_test1&mediaType=live"
```

Verify:
- App launches successfully
- Navigates directly to specified content
- Plays immediately (if applicable)
- Returns to home on back button

See [DEEP_LINKING.md](DEEP_LINKING.md) for details.

---

## 4. Content Requirements

- [ ] **NO copyrighted content** included in the package
- [ ] **NO pirated streams** in sample playlists
- [ ] **Legal notice** displayed on first run
- [ ] **User-supplied content only** - app does not provide streams

**Acceptable sample content:**
- Public domain test streams
- Your own licensed content
- Links to legal, publicly available streams
- Demo/test HLS feeds (Big Buck Bunny, Tears of Steel, etc.)

---

## 5. Functionality Testing

Test on multiple Roku devices (HD and 4K):

### Core Features
- [ ] App launches without crashes
- [ ] UI is responsive and navigable
- [ ] Text is readable on HD (720p) screens
- [ ] Focus indicators are visible
- [ ] Back button works correctly
- [ ] Home button exits gracefully

### IPTV Features
- [ ] Add playlist from URL
- [ ] Parse M3U with 100+ channels
- [ ] Browse channels by groups
- [ ] Play HLS streams
- [ ] Handle network errors gracefully
- [ ] Display EPG data (if XMLTV provided)
- [ ] Captions toggle (if stream has CC)

### Edge Cases
- [ ] Empty playlist URL
- [ ] Malformed M3U file
- [ ] Unreachable stream URL
- [ ] Network timeout
- [ ] Invalid XMLTV data
- [ ] Rapid navigation and button presses

---

## 6. Performance Requirements

- [ ] **Launch time** - App shows content within 5 seconds
- [ ] **Memory usage** - No leaks or excessive consumption
- [ ] **Network** - Handles slow connections gracefully
- [ ] **Buffering** - Shows loading indicators
- [ ] **Parsing** - Large playlists (1000+ channels) load within reasonable time

Monitor via telnet console:

```bash
telnet ROKU_IP 8085
```

---

## 7. Accessibility

- [ ] Focus indicators are clearly visible
- [ ] Text size is readable (min 18pt on HD)
- [ ] High contrast between text and background
- [ ] Closed captions supported (when available in stream)
- [ ] Keyboard navigation works (if implemented)

---

## 8. Localization (Optional)

If supporting multiple languages:

- [ ] Translations for all UI strings
- [ ] Proper encoding (UTF-8)
- [ ] Locale-specific date/time formats
- [ ] Test with Roku's language settings

Dartt's IPTV 1.0 targets **English only** - add localization in future versions.

---

## 9. Channel Store Listing

Prepare assets for submission:

### Screenshots (Required)
- Minimum 2, maximum 10
- 1920×1080 or 1280×720 PNG/JPG
- Show actual app functionality
- No logos, banners, or promotional text

### Description (Required)
- Clear, concise explanation of app functionality
- Mention it's a **player only** (no content provided)
- Legal disclaimer about user-supplied streams
- Max 500 characters

### Category (Required)
Choose: **Video Streaming** or **Media Players**

### Content Rating (Required)
- Choose appropriate rating
- For user-supplied content, select **Not Rated** or **General Audience**
- Explain in notes: "Content depends on user-supplied streams"

### Support Information (Required)
- **Email**: Provide valid support email
- **Website**: Link to GitHub repo or documentation
- **Privacy Policy**: Required if collecting any data (even if just "no data collected")

---

## 10. Submission Process

1. Log in to [developer.roku.com](https://developer.roku.com)
2. Go to **Manage My Channels**
3. Click **Add Public Channel**
4. Fill in channel information
5. Upload package ZIP
6. Upload screenshots and images
7. Submit for review

**Review time:** Typically 5-10 business days

---

## 11. Post-Submission

After submission:

- [ ] Monitor email for Roku feedback
- [ ] Address any certification issues promptly
- [ ] Update package if changes required
- [ ] Respond to QA questions within 48 hours

Common rejection reasons:
- Missing images or incorrect sizes
- Crashes or bugs
- Poor UI/UX
- Deep linking not working
- Legal/content policy violations

---

## 12. Versioning and Updates

For future updates:

1. Increment `build_version` in manifest
2. Update changelog
3. Test thoroughly
4. Package and upload
5. Roku reviews update (faster than initial submission)

---

## Additional Resources

- [Roku Developer Portal](https://developer.roku.com)
- [Roku Certification Criteria](https://developer.roku.com/docs/developer-program/certification/certification.md)
- [Deep Linking Guide](https://developer.roku.com/docs/developer-program/discovery/deep-linking.md)
- [Design Guidelines](https://developer.roku.com/design/design-guidelines.md)
- [Channel Publishing](https://developer.roku.com/docs/developer-program/publishing/channel-publishing.md)

---

**Good luck with your submission! 🚀**
