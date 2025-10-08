# 🔧 Sideload Troubleshooting Guide

**Issue:** `make dev` fails with "Installation failed - Unknown error"

---

## Quick Fix Options

### Option 1: Set Password Environment Variable (Recommended)

```bash
# Use this command with YOUR actual Roku developer password:
make dev ROKU_IP="192.168.68.121" ROKU_PASS="your_password_here"
```

**Replace `your_password_here` with your actual Roku developer password.**

---

### Option 2: Create Password File

```bash
cd /Users/aarondartt/Documents/Dartts_IPTV

# Create password file (will be ignored by git)
echo "your_password_here" > .roku_password

# Now you can use make dev without specifying password
make dev ROKU_IP="192.168.68.121"
```

---

### Option 3: Manual Sideload via Browser

If the make command continues to fail, you can sideload manually:

1. **Open your browser** and go to: `http://192.168.68.121`

2. **Login** with:
   - Username: `rokudev`
   - Password: (your developer password)

3. **Delete existing dev channel** (if any):
   - Click "Delete" button under "Development Application Installer"

4. **Upload new package**:
   - Click "Browse" button
   - Select: `/Users/aarondartt/Documents/Dartts_IPTV/dist/DarttsIPTV.zip`
   - Click "Install"

5. **Verify installation**:
   - Should see "Install Success" message
   - Channel will launch automatically

---

## Understanding the Roku Developer Password

### What is it?
- The password you set when you enabled Developer Mode on your Roku
- Default is often: `rokudev`
- You may have changed it to something else

### How to find/reset it:

1. **On your Roku remote**, press this sequence:
   - Home (3x)
   - Up (2x)
   - Right, Left, Right, Left, Right

2. **Enable Developer Mode**:
   - If not already enabled, enable it
   - Note the password shown/set

3. **Note the IP address** displayed (should be 192.168.68.121)

---

## Testing the Connection

### Test 1: Can you reach the Roku web interface?

```bash
# Should return HTML content
curl -s http://192.168.68.121 | head -20
```

**Expected:** HTML content with "Developer Settings" or similar

### Test 2: Check authentication

```bash
# Replace YOUR_PASSWORD with your actual password
curl -u "rokudev:YOUR_PASSWORD" http://192.168.68.121/plugin_install | head -20
```

**Expected:** HTML form content (not "Unauthorized")

### Test 3: Test with explicit credentials

```bash
cd /Users/aarondartt/Documents/Dartts_IPTV
ROKU_PASS="YOUR_PASSWORD" bash scripts/sideload.sh 192.168.68.121 rokudev YOUR_PASSWORD build
```

**Expected:** "Channel installed successfully"

---

## Common Issues and Solutions

### Issue: "Unauthorized" or 401 Error
**Solution:** Wrong password
```bash
# Try with the default password first
make dev ROKU_IP="192.168.68.121" ROKU_PASS="rokudev"
```

### Issue: "Connection refused"
**Solution:** Developer mode not enabled or wrong IP
- Double-check IP address on Roku
- Re-enable developer mode on Roku

### Issue: "Identical to previous version"
**Solution:** Need to force reinstall
```bash
# Manually delete via browser first, then:
make dev ROKU_IP="192.168.68.121" ROKU_PASS="your_password"
```

### Issue: Build succeeds but sideload fails
**Solution:** Use manual browser upload as fallback
- The package is already built at `dist/DarttsIPTV.zip`
- Just upload it via the web interface

---

## Recommended Workflow

### For First Time Setup:

1. **Create password file** (one time):
   ```bash
   cd /Users/aarondartt/Documents/Dartts_IPTV
   echo "your_actual_password" > .roku_password
   chmod 600 .roku_password  # Secure the file
   ```

2. **Add to .gitignore** (already done):
   ```bash
   # .roku_password is already in .gitignore
   ```

3. **Test sideload**:
   ```bash
   make dev ROKU_IP="192.168.68.121"
   ```

### For Regular Development:

Once password file is set up:
```bash
# Just use this every time:
make dev ROKU_IP="192.168.68.121"
```

---

## Alternative: Use Pre-built Package

If automated sideload keeps failing, you can always:

1. **Build the package:**
   ```bash
   make package
   ```

2. **Upload via browser:**
   - Open: http://192.168.68.121
   - Upload: `dist/DarttsIPTV.zip`

This is actually the most reliable method and what Roku officially recommends!

---

## Next Steps

### Try this command (replace password):

```bash
cd /Users/aarondartt/Documents/Dartts_IPTV
make clean
make dev ROKU_IP="192.168.68.121" ROKU_PASS="your_actual_password"
```

### If that fails, run this for detailed error:

```bash
cd /Users/aarondartt/Documents/Dartts_IPTV
make build
bash scripts/sideload.sh 192.168.68.121 rokudev your_actual_password build
```

This will show the full response from the Roku device.

### If all else fails:

**Just use the browser method!** It's actually easier and more reliable:
- Go to: http://192.168.68.121
- Upload: dist/DarttsIPTV.zip
- Done! ✅

---

## Quick Reference

```bash
# Build only (no sideload)
make package

# Sideload with password in command
make dev ROKU_IP="192.168.68.121" ROKU_PASS="mypassword"

# Sideload with password file
echo "mypassword" > .roku_password
make dev ROKU_IP="192.168.68.121"

# Manual browser upload
open http://192.168.68.121
# Upload: dist/DarttsIPTV.zip
```

---

## Summary

**Most likely issue:** The `ROKU_PASS` environment variable is not set or is incorrect.

**Quick fix:** 
```bash
make dev ROKU_IP="192.168.68.121" ROKU_PASS="your_password"
```

**Easiest alternative:** Use browser at http://192.168.68.121 to upload `dist/DarttsIPTV.zip`

---

_Need more help? Check the updated sideload script output for detailed error messages._
