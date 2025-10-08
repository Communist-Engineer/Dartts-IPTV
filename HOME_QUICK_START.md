# Home Page V1 - Quick Start Guide

## Build & Deploy (One Command)
```bash
make dev ROKU_IP="192.168.68.121" ROKU_PASS="admn"
```

## Monitor Runtime Logs
```bash
nc 192.168.68.121 8085
```

## Test Checklist

### ✅ First Launch
- [ ] First-run dialog appears with legal notice
- [ ] Home shows "Get started by adding a playlist"
- [ ] Add Playlist button is focused (purple border)
- [ ] Can open Add Playlist dialog and enter URL
- [ ] After adding playlist, loading state appears
- [ ] Home updates with channel counts

### ✅ Navigation
- [ ] Left arrow moves focus left (wraps at ends)
- [ ] Right arrow moves focus right (wraps at ends)
- [ ] Up arrow moves between rows
- [ ] Down arrow moves between rows  
- [ ] Focus indicator (purple border) follows selection
- [ ] Back button exits app from Home

### ✅ Menu Items
- [ ] Add Playlist → Opens keyboard dialog, accepts URL, saves
- [ ] Playlists → Opens Settings modal
- [ ] All Channels → Shows channel list (if channels loaded)
- [ ] Groups → Shows first group or error message
- [ ] Favorites → Shows favorites or "no favorites" message
- [ ] Recents → Shows recents or "no recents" message
- [ ] Guide → Shows "coming soon" message
- [ ] Settings → Opens settings modal

### ✅ Settings Modal
- [ ] Modal opens with focus on first option
- [ ] Up/Down navigation works
- [ ] Add Playlist opens keyboard dialog
- [ ] Manage Playlists shows list of URLs
- [ ] Clear Cache asks for confirmation
- [ ] About shows app info
- [ ] Close returns to Home
- [ ] Back button closes modal

### ✅ Error Handling
- [ ] Invalid playlist URL shows error banner
- [ ] Network error shows friendly message
- [ ] Empty states (no channels, no favorites) show helpful text
- [ ] UI remains responsive during errors

### ✅ Back Navigation
- [ ] From channel list → Back returns to Home
- [ ] From Settings modal → Back closes and returns to Home
- [ ] From Home → Back exits app
- [ ] Focus restored correctly after returning

### ✅ Performance
- [ ] Home appears within 500ms (with cached data)
- [ ] No UI freezing during playlist load
- [ ] Loading indicator spins during background tasks
- [ ] Smooth focus transitions

## Expected Log Output (First Launch)
```
[INFO] [HOME] Initializing Home Scene
[INFO] [HOME] First run detected - showing legal notice
[INFO] [HOME] First run notice acknowledged
[INFO] [HOME] Loading settings and cache
[INFO] [HOME] No cached data available
[INFO] [HOME] Showing first-run state (no playlists)
[DEBUG] [HOME] Focus set to: addPlaylist
[INFO] [HOME] Home Scene initialized
```

## Expected Log Output (With Playlist)
```
[INFO] [HOME] Initializing Home Scene
[INFO] [HOME] Loading settings and cache
[INFO] [HOME] Showing skeleton/loading state
[INFO] [HOME] Starting background playlist load
[INFO] [PlaylistLoader] Fetching playlist: http://example.com/playlist.m3u
[INFO] [PlaylistLoader] Loaded 150 channels
[INFO] [HOME] Playlist load completed with status: complete
[INFO] [HOME] Cache saved
[DEBUG] [HOME] UI updated with current data
```

## Common Issues

### Issue: "SUB or FUNCTION defined twice"
**Solution:** Ensure `source/components/` directory does NOT exist. Run:
```bash
rm -rf source/components
make clean
make dev ROKU_IP="192.168.68.121" ROKU_PASS="admn"
```

### Issue: No log output from Home
**Problem:** App might be running old MainScene  
**Solution:** Verify `source/main.brs` creates `AppScene` (not `MainScene`)

### Issue: Compilation warnings
**Status:** 3 unused variable warnings are cosmetic only (safe to ignore)

### Issue: Cannot connect to debug console
**Solution:** Check Roku IP address and ensure device is on same network

## Quick Commands

```bash
# Full rebuild
make clean && make dev ROKU_IP="192.168.68.121" ROKU_PASS="admn"

# Monitor logs continuously
nc 192.168.68.121 8085

# Check build directory structure
tree build/ -L 3

# Verify no old component files in source
ls -la source/ | grep components

# Check component structure
ls -la components/home/
```

## Device Requirements
- Roku OS 9.0 or later
- Developer mode enabled
- Network accessible from build machine

## Success Criteria
✅ App compiles without errors  
✅ Home page renders immediately  
✅ All 8 menu items respond to selection  
✅ Navigation feels natural and responsive  
✅ No crashes or freezes  
✅ Settings persist across app restarts

## Video Recording Tips
1. Start app from scratch (first run)
2. Acknowledge legal notice
3. Navigate through all menu items with D-pad
4. Add a test playlist
5. Show loading state
6. Navigate to All Channels
7. Return to Home with Back
8. Open Settings, test options
9. Demonstrate wrap-around navigation
10. Exit app with Back from Home

---
**Ready to test!** Deploy to your Roku and run through the checklist above.
