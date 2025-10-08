# ✅ Sideload Authentication Fix

**Issue:** `make dev` failed with "Installation failed - Unknown error"  
**Root Cause:** Roku requires Digest authentication, script was using Basic auth  
**Status:** ✅ **FIXED**  
**Date:** October 8, 2025

---

## Problem Summary

### What Was Happening
```bash
make dev ROKU_IP="192.168.68.121" ROKU_PASS="admn"
# Result: ❌ Installation failed - Unknown error
```

Even though the credentials were correct and working in the browser, the automated sideload script was failing silently.

---

## Root Cause Analysis

### Discovery Process

1. **Tested build step** - ✅ Working fine
2. **Ran sideload script with debug** - Empty response from Roku
3. **Tested curl directly** - Got HTTP 401 with this header:
   ```
   WWW-Authenticate: Digest qop="auth", realm="rokudev", nonce="..."
   ```

### The Issue

Roku's web installer uses **Digest Authentication**, not Basic Authentication.

**What we were doing (wrong):**
```bash
curl -u "rokudev:admn" http://...
# Uses Basic auth by default
```

**What Roku requires:**
```bash
curl --digest -u "rokudev:admn" http://...
# Uses Digest authentication
```

---

## The Fix

### Changes Made

**File:** `scripts/sideload.sh`

**Before:**
```bash
curl -s -S -u "$ROKU_USER:$ROKU_PASS" \
    -F "mysubmit=Install" \
    -F "archive=@$TMP_ZIP" \
    "http://$ROKU_IP/plugin_install"
```

**After:**
```bash
curl -s -S --digest -u "$ROKU_USER:$ROKU_PASS" \
    -F "mysubmit=Install" \
    -F "archive=@$TMP_ZIP" \
    "http://$ROKU_IP/plugin_install"
```

**Change:** Added `--digest` flag to both curl commands (delete and install)

---

## Verification

### Test 1: Direct Script Execution ✅
```bash
bash scripts/sideload.sh 192.168.68.121 rokudev admn build
```
**Result:**
```
✓ Channel installed successfully
Launching channel...
Channel is running on your Roku!
```

### Test 2: Make Command ✅
```bash
make dev ROKU_IP="192.168.68.121" ROKU_PASS="admn"
```
**Result:**
```
Building DarttsIPTV...
✓ Build complete
Sideloading to Roku at 192.168.68.121...
✓ Channel installed successfully
✓ Development build deployed to Roku
```

---

## How to Use

### Now Working Command:
```bash
cd /Users/aarondartt/Documents/Dartts_IPTV
make dev ROKU_IP="192.168.68.121" ROKU_PASS="admn"
```

### Or with Password File:
```bash
# One time setup
echo "admn" > .roku_password

# Then just use:
make dev ROKU_IP="192.168.68.121"
```

---

## Technical Details

### What is Digest Authentication?

**Basic Auth:**
- Sends credentials as Base64-encoded string
- Less secure (easily decoded)
- Single request

**Digest Auth:** (What Roku uses)
- Server sends a "nonce" (random number)
- Client hashes credentials with nonce
- More secure (credentials never sent in clear)
- Requires two requests (challenge-response)

### Why Curl Needs --digest Flag

When curl sees a 401 with `WWW-Authenticate: Digest`, it needs `--digest` flag to:
1. Receive the initial challenge
2. Calculate the proper hash
3. Retry with the hashed credentials

Without the flag, curl uses Basic auth and gets rejected.

---

## Troubleshooting

### If sideload still fails:

1. **Verify credentials work in browser:**
   - Open: http://192.168.68.121
   - Login with: rokudev / admn

2. **Check developer mode is enabled:**
   - On Roku remote: Home (3x), Up (2x), Right, Left, Right, Left, Right

3. **Test curl manually:**
   ```bash
   curl --digest -u rokudev:admn http://192.168.68.121/plugin_install
   ```
   Should return HTML, not 401

4. **Check the package exists:**
   ```bash
   ls -lh dist/DarttsIPTV.zip
   # Should show 192K
   ```

---

## Common Issues Resolved

### ❌ Before Fix
- Silent failures with empty responses
- "Unknown error" messages
- Working credentials still rejected
- Browser upload worked, script didn't

### ✅ After Fix
- Clear success/failure messages
- Proper authentication
- Automated sideload works
- Consistent with browser behavior

---

## Development Workflow Now

### Quick Development Loop:
```bash
# Edit code in source/
make dev ROKU_IP="192.168.68.121" ROKU_PASS="admn"
# Channel automatically rebuilds, sideloads, and launches
```

### Monitor Debug Output:
```bash
# In another terminal:
nc 192.168.68.121 8085
# Shows live console output from channel
```

### Iterate Quickly:
```bash
# Make changes, then:
make dev ROKU_IP="192.168.68.121" ROKU_PASS="admn"
# Repeat!
```

---

## Git Changes

**Commit:** f552efa  
**Message:** "Fix sideload script: Add --digest flag for Roku authentication"  
**Files Changed:** `scripts/sideload.sh` (2 lines)  
**Branch:** main  
**Status:** Pushed to GitHub

---

## Summary

✅ **Identified:** Roku uses Digest auth, not Basic auth  
✅ **Fixed:** Added `--digest` flag to curl commands  
✅ **Tested:** Both direct script and make command work  
✅ **Committed:** Changes pushed to repository  
✅ **Documented:** Full troubleshooting guide available  

**The automated sideload workflow now works perfectly!** 🎉

---

## Next Steps

1. **Test the app on your Roku:**
   - Should see splash screen
   - Then home screen appears
   - First-run legal notice displays

2. **Check debug console:**
   ```bash
   nc 192.168.68.121 8085
   ```
   - Should show no errors
   - HomeScene should initialize

3. **Try adding a playlist:**
   - Settings → Add Playlist URL
   - Test playback

---

_Authentication issue resolved: October 8, 2025_
