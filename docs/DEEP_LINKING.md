# Deep Linking Guide

This document explains how to implement and test deep linking in Dartt's IPTV.

---

## What is Deep Linking?

Deep linking allows external applications, voice assistants (Alexa, Google), or automation scripts to launch your Roku channel and navigate directly to specific content.

**Example:**
```bash
curl -d '' "http://ROKU_IP:8060/launch/dev?contentId=sample_test1&mediaType=live"
```

This launches the dev channel and immediately starts playback of the channel with ID `sample_test1`.

---

## Implementation in Dartt's IPTV

### 1. Launch Arguments

When Roku launches the channel with parameters, they are passed to `main.brs`:

```brightscript
function GetDeepLinkArgs() as object
    launchParams = CreateObject("roInput")
    if launchParams <> invalid then
        inputData = launchParams.GetMessage()
        if type(inputData) = "roAssociativeArray" then
            return inputData
        end if
    end if
    return {}
end function
```

### 2. Scene Routing

Launch args are passed to the root scene (`AppScene`), which forwards them to `HomeScene`:

```brightscript
sub AppSceneInit()
    m.homeScene = m.top.FindNode("homeScene")
    m.top.ObserveField("launchArgs", "AppSceneOnLaunchArgsChanged")
    
    if m.top.launchArgs <> invalid and m.top.launchArgs.Count() > 0 then
        m.homeScene.launchArgs = m.top.launchArgs
    end if
end sub
```

### 3. Content Lookup

`HomeScene` receives the `launchArgs` and handles navigation:

```brightscript
sub HomeSceneOnLaunchArgsChanged()
    args = m.top.launchArgs
    if args <> invalid and args.contentId <> invalid then
        ' Find channel by contentId
        channel = FindChannelById(args.contentId)
        if channel <> invalid then
            ' Launch player
            LaunchPlayer(channel)
        end if
    end if
end sub
```

---

## Deep Link Parameters

Roku passes parameters as key-value pairs:

| Parameter      | Type   | Description                          | Example          |
|----------------|--------|--------------------------------------|------------------|
| `contentId`    | string | Unique identifier for content        | `sample_test1`   |
| `mediaType`    | string | Type of content (optional)           | `live`, `video`  |
| `instant`      | bool   | Auto-play immediately (optional)     | `true`, `false`  |

### Dartt's IPTV Usage

- **contentId** - Maps to channel ID or stream URL hash
- **mediaType** - `live` for IPTV streams
- **instant** - If `true`, starts playback immediately

---

## Testing Deep Linking

### 1. Via ECP (External Control Protocol)

Launch channel with parameters:

```bash
curl -d '' "http://192.168.1.100:8060/launch/dev?contentId=sample_test1&mediaType=live"
```

### 2. Via Roku Deep Linking Tester

Roku provides a testing tool:

1. Sideload the **Deep Linking Tester** channel
2. Enter your dev channel app ID: `dev`
3. Enter content ID: `sample_test1`
4. Select media type: `live`
5. Launch

### 3. Automated Test Script

Use the included integration test:

```bash
cd tests/integration
ROKU_IP=192.168.1.100 bash test_deep_linking.sh
```

This script:
- Launches the app
- Sends a deep link command
- Verifies navigation (manual check)

---

## Content Catalog

For certification, provide a `deep_link_catalog.json` file that describes available content:

```json
{
  "providerName": "Dartt's IPTV",
  "language": "en",
  "liveFeeds": [
    {
      "id": "sample_test1",
      "title": "Test Channel HD",
      "content": {
        "videos": [
          {
            "url": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
            "quality": "HD",
            "videoType": "HLS"
          }
        ]
      },
      "thumbnail": "https://example.com/logo1.png",
      "genres": ["entertainment"],
      "tags": ["sample", "test"]
    }
  ]
}
```

Place this file in `samples/deep_link_catalog.json`.

---

## Mapping Content IDs

Dartt's IPTV generates channel IDs from stream URLs:

```brightscript
function GenerateChannelId(meta as object, streamUrl as string) as string
    digestSource = streamUrl + "|" + meta.name + "|" + meta.tvgId
    return ShortHash(digestSource)
end function
```

To find a channel's ID:
1. Load the playlist
2. Check telnet logs for parsed channel IDs
3. Or manually compute the hash

**Alternatively**, use the `tvg-id` attribute from your M3U as the `contentId`.

---

## Best Practices

### For Certification

1. **Support all required parameters**
   - At minimum: `contentId`
   - Recommended: `mediaType`, `instant`

2. **Handle missing content gracefully**
   - If `contentId` not found, show error or return to home
   - Don't crash

3. **Test thoroughly**
   - Multiple content IDs
   - Invalid IDs
   - Empty parameters
   - Rapid repeated launches

4. **Document available content**
   - Provide catalog JSON
   - List all valid `contentId` values
   - Include in submission notes

### For Users

Deep linking enables:
- **Voice control**: "Alexa, open Test Channel on Dartt's IPTV"
- **Home automation**: Launch specific channels via scripts
- **External apps**: Integrate with media center software

---

## Example Use Cases

### 1. Launch Favorite Channel

```bash
curl -d '' "http://ROKU_IP:8060/launch/dev?contentId=espn_hd&mediaType=live&instant=true"
```

### 2. Integration with Home Assistant

```yaml
script:
  watch_news:
    sequence:
      - service: rest_command.roku_launch
        data:
          roku_ip: "192.168.1.100"
          content_id: "cnn_live"
```

### 3. Scheduled Channel Launch

```bash
# Cron job to launch morning news at 7 AM
0 7 * * * curl -d '' "http://192.168.1.100:8060/launch/dev?contentId=morning_news"
```

---

## Troubleshooting

### Deep link doesn't navigate to content

- Check telnet logs for errors
- Verify `contentId` exists in loaded playlist
- Ensure `HomeSceneOnLaunchArgsChanged` is implemented
- Test with sample content first

### App launches but doesn't auto-play

- Verify `instant=true` is set
- Ensure player scene is initialized
- Check for network errors preventing stream load

### Certification rejected for deep linking

- Provide valid `deep_link_catalog.json`
- Test with Roku's Deep Linking Tester
- Document all valid `contentId` values
- Handle edge cases (missing ID, network failure)

---

## ECP Reference

External Control Protocol commands:

| Command       | URL                                                  | Description           |
|---------------|------------------------------------------------------|-----------------------|
| Launch        | `http://IP:8060/launch/APP_ID?params`               | Launch with params    |
| Home          | `http://IP:8060/keypress/Home`                      | Press Home button     |
| Back          | `http://IP:8060/keypress/Back`                      | Press Back button     |
| Query Apps    | `http://IP:8060/query/apps`                         | List installed apps   |
| Query Device  | `http://IP:8060/query/device-info`                  | Device information    |

---

## Additional Resources

- [Roku Deep Linking Documentation](https://developer.roku.com/docs/developer-program/discovery/deep-linking.md)
- [ECP Specification](https://developer.roku.com/docs/developer-program/debugging/external-control-api.md)
- [Certification Requirements](https://developer.roku.com/docs/developer-program/certification/certification.md)

---

**Happy linking! 🔗**
