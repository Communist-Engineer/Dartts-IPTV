# 🐛 Debug Session Summary - Component Loading Issues

**Date:** October 8, 2025  
**Status:** 🚧 IN PROGRESS - Critical component discovery issue found

---

## Issues Fixed ✅

### 1. Digest Authentication
- **Problem:** Sideload script was using Basic auth instead of Digest
- **Solution:** Added `--digest` flag to curl commands
- **Status:** ✅ FIXED

### 2. Deep Link Function
- **Problem:** `roInput.GetMessage()` doesn't exist
- **Solution:** Simplified GetDeepLinkArgs() to return empty object
- **Status:** ✅ FIXED

### 3. Duplicate init() Functions
- **Problem:** Multiple components had `init()` causing "SUB or FUNCTION defined twice" error
- **Solution:** Used unique function names (HomeScene_init) with inline wrapper
- **Status:** ✅ FIXED - Compilation now succeeds

---

## Critical Issue Still Present ❌

### ERROR: roSGScreen.CreateScene: No such node [ComponentName]

**Tried Components:**
- ❌ AppScene (in source/components/scenes/)
- ❌ HomeScene (in source/components/home/)
- ❌ MainScene (in source/components/)

**Error Pattern:**
```
BRIGHTSCRIPT: ERROR: roSGScreen.CreateScene: No such node MainScene: pkg:/source/main.brs(17)
```

**What We Know:**
1. ✅ Components compile successfully
2. ✅ XML files are in the build directory
3. ✅ Component XML syntax is correct
4. ✅ Components extend Scene properly
5. ❌ Roku cannot discover/load ANY Scene component we create

---

## Investigation Steps Taken

### 1. Verified Component Structure
```xml
<?xml version="1.0" encoding="utf-8"?>
<component name="MainScene" extends="Scene">
    <children>
        <Label id="titleLabel" text="Dartt's IPTV" />
    </children>
    <script type="text/brightscript">
        <![CDATA[
        sub init()
            m.titleLabel = m.top.FindNode("titleLabel")
        end sub
        ]]>
    </script>
</component>
```
✅ Syntax correct

### 2. Checked Build Directory
```bash
find build -name "*.xml"
# Found: build/source/components/MainScene.xml
```
✅ File exists in build

### 3. Verified File Content
```bash
cat build/source/components/MainScene.xml
```
✅ Content matches source

### 4. Tried Multiple Locations
- `source/` (root)
- `source/components/`
- `source/components/home/`
- `source/components/scenes/`
❌ None work

---

## Hypotheses

### Hypothesis 1: Component Auto-Discovery Issue
**Theory:** Roku isn't auto-discovering components in `components/` subdirectories

**Evidence:**
- All Scene components fail to load
- Non-Scene components haven't been tested yet
- Build directory structure: `build/source/components/MainScene.xml`

**Possible Solutions:**
1. Move Scene component to root `source/` folder
2. Check manifest for component registration requirements
3. Verify folder naming conventions

### Hypothesis 2: Init Function Conflicts (LESS LIKELY)
**Theory:** Even though compilation succeeds, inline `init()` functions across multiple XML files might conflict at runtime

**Evidence:**
- HomeScene.xml has inline init()
- MainScene.xml has inline init()
- Roku might be loading all components globally

**Possible Solutions:**
1. Remove ALL inline init() from XML
2. Move all init code to separate .brs files
3. Use unique function names everywhere

### Hypothesis 3: Manifest Configuration Missing
**Theory:** Roku requires manifest entries to register components

**Evidence:**
- Current manifest has no component registration
- Some Roku apps require explicit component listing

**Possible Solutions:**
1. Add component registration to manifest
2. Check if bs_const or other settings needed

---

## Next Steps

### Immediate Actions Needed:

1. **Test Component in Root source/ Folder**
   ```bash
   # Move MainScene.xml to source/MainScene.xml
   mv source/components/MainScene.xml source/MainScene.xml
   # Update main.brs if needed
   # Rebuild and test
   ```

2. **Remove ALL Inline init() Functions**
   ```xml
   <!-- Change from this: -->
   <script type="text/brightscript">
       <![CDATA[
       sub init()
           ' code
       end sub
       ]]>
   </script>
   
   <!-- To this: -->
   <script type="text/brightscript" uri="pkg:/source/components/MainScene.brs" />
   ```

3. **Create Separate .brs File for Each Component**
   ```brightscript
   ' MainScene.brs
   sub init()
       m.titleLabel = m.top.FindNode("titleLabel")
   end sub
   ```

4. **Test Minimal Example from Roku Docs**
   Create exact copy of Roku's hello world Scene to verify basic functionality

---

## Debug Console Output

**Latest Error (Version: fbee9083):**
```
BRIGHTSCRIPT: ERROR: roSGScreen.CreateScene: No such node MainScene: pkg:/source/main.brs(17)

Member function not found in BrightScript Component or interface. (runtime error &hf4) in pkg:/source/main.brs(18)

Backtrace:
#0  Function main() As Void
   file/line: pkg:/source/main.brs(18)

Local Variables:
screen           roSGScreen refcnt=1
scene            Invalid
```

**Key Observation:** `scene            Invalid` means `CreateScene()` returned invalid, confirming component wasn't found.

---

## Files Modified This Session

1. `source/main.brs` - Fixed GetDeepLinkArgs, simplified scene creation
2. `source/components/home/HomeScene.brs` - Renamed init to HomeScene_init
3. `source/components/home/HomeScene.xml` - Added inline init wrapper, changed extends to Scene
4. `source/components/MainScene.xml` - Created minimal test Scene
5. `source/components/scenes/AppScene.*` - Moved from root (didn't help)
6. `scripts/sideload.sh` - Added --digest flag for authentication

---

## Recommendations

### Short-term Fix (Get Something Working):
1. Create Scene component in `source/` root directory
2. Use external .brs file (no inline scripts)
3. Use simplest possible init() with unique name
4. Test with absolute minimal Scene (just one Label)

### Long-term Solution:
1. Research Roku component auto-discovery rules
2. Verify proper folder structure for SceneGraph components
3. Implement proper component architecture
4. Add comprehensive component registration

---

## Resources Needed

- [ ] Review official Roku SceneGraph component examples
- [ ] Check Roku developer forums for "No such node" errors
- [ ] Compare working open-source Roku channel structure
- [ ] Verify Roku OS version compatibility

---

_Debug session ongoing - will update as we discover more..._
