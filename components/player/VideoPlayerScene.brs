' ============================
' Logger Helper Functions
' ============================
sub LogDebug(tag as string, message as string)
    print "[DEBUG] [" + tag + "] " + message
end sub

sub LogInfo(tag as string, message as string)
    print "[INFO] [" + tag + "] " + message
end sub

sub LogWarn(tag as string, message as string)
    print "[WARN] [" + tag + "] " + message
end sub

sub LogError(tag as string, message as string)
    print "[ERROR] [" + tag + "] " + message
end sub

sub init()
    LogInfo("VideoPlayer", "Initializing Video Player Scene")
    
    m.videoNode = m.top.FindNode("videoNode")
    m.playerOverlay = m.top.FindNode("playerOverlay")
    m.loadingBg = m.top.FindNode("loadingBg")
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.errorLabel = m.top.FindNode("errorLabel")
    
    if m.videoNode <> invalid then
        ' Configure video scaling to fit screen properly
        ' Using 720p as it's a common resolution and should scale better
        m.videoNode.width = 1280
        m.videoNode.height = 720
        m.videoNode.translation = [0, 0]
        
        ' Set video to fill the available space while maintaining aspect ratio
        ' This prevents distortion but may add letterboxing/pillarboxing
        m.videoNode.enableUI = false
        m.videoNode.notificationInterval = 1
        
        ' Observe fields for state management
        m.top.ObserveField("channel", "VideoPlayerOnChannelChanged")
        m.videoNode.ObserveField("state", "VideoPlayerOnStateChanged")
        m.videoNode.ObserveField("position", "VideoPlayerOnPositionChanged")
        m.videoNode.setFocus(true)
        
        LogInfo("VideoPlayer", "Video node configured: 1280x720")
    else
        LogError("VideoPlayer", "Failed to find videoNode")
    end if
    
    m.overlayTimer = invalid
    
    LogInfo("VideoPlayer", "Video Player Scene initialized")
end sub

sub VideoPlayerOnChannelChanged()
    channel = m.top.channel
    if channel = invalid then return
    
    LogInfo("VideoPlayer", "Loading channel: " + channel.title)
    
    ShowLoading()
    
    content = CreateObject("roSGNode", "ContentNode")
    content.title = channel.title
    
    if channel.DoesExist("group") and channel.group <> invalid then
        content.description = channel.group
    else
        content.description = ""
    end if
    
    content.url = channel.streamUrl
    
    ' Set stream format based on URL
    streamUrl = channel.streamUrl
    if Instr(1, streamUrl, ".m3u8") > 0 or Instr(1, streamUrl, "/live/") > 0 then
        content.streamFormat = "hls"
    else if Instr(1, streamUrl, ".mp4") > 0 then
        content.streamFormat = "mp4"
    else
        content.streamFormat = "hls" ' Default to HLS for live streams
    end if
    
    ' Set video quality - the URL contains "/sd" which suggests SD quality
    ' SD streams are typically 640x480 (4:3) or 854x480 (16:9)
    ' Let Roku handle the scaling automatically
    
    LogInfo("VideoPlayer", "Stream URL: " + channel.streamUrl)
    LogInfo("VideoPlayer", "Stream format: " + content.streamFormat)
    
    if channel.DoesExist("logo") and channel.logo <> invalid and channel.logo <> "" then
        content.hdPosterUrl = channel.logo
        content.sdPosterUrl = channel.logo
    end if
    
    ' Check for subtitle tracks if available
    if channel.DoesExist("subtitles") and channel.subtitles <> invalid then
        content.SubtitleTracks = channel.subtitles
    end if
    
    m.videoNode.content = content
    m.videoNode.control = "play"
    
    if m.playerOverlay <> invalid then
        m.playerOverlay.channel = channel
    end if
    ShowOverlay()
end sub

sub VideoPlayerOnStateChanged()
    state = m.videoNode.state
    
    if state = "playing" then
        HideLoading()
        LogInfo("VideoPlayer", "Playback started")
    else if state = "buffering" then
        ShowLoading()
    else if state = "paused" then
        ShowOverlay()
    else if state = "error" then
        HideLoading()
        ShowError("Playback error. Check stream URL or format.")
    else if state = "finished" then
        HideLoading()
        m.top.closeRequested = true
    end if
end sub

sub VideoPlayerOnPositionChanged()
    ' Update overlay with current position if needed
end sub

sub ShowLoading()
    m.loadingBg.visible = true
    m.loadingLabel.visible = true
    m.errorLabel.visible = false
end sub

sub HideLoading()
    m.loadingBg.visible = false
    m.loadingLabel.visible = false
end sub

sub ShowError(message as string)
    m.errorLabel.text = message
    m.errorLabel.visible = true
    m.loadingBg.visible = true
    
    ' Auto-hide error after 5 seconds
    timer = CreateObject("roSGNode", "Timer")
    timer.duration = 5
    timer.repeat = false
    timer.ObserveField("fire", "HideError")
    m.errorTimer = timer
    timer.control = "start"
end sub

sub HideError()
    m.errorLabel.visible = false
    m.loadingBg.visible = false
end sub

sub ShowOverlay()
    if m.playerOverlay <> invalid then
        m.playerOverlay.showInfo = true
    end if
    
    ' Auto-hide overlay after 3 seconds
    if m.overlayTimer <> invalid then
        m.overlayTimer.control = "stop"
    end if
    
    timer = CreateObject("roSGNode", "Timer")
    timer.duration = 3
    timer.repeat = false
    timer.ObserveField("fire", "HideOverlay")
    m.overlayTimer = timer
    timer.control = "start"
end sub

sub HideOverlay()
    if m.playerOverlay <> invalid then
        m.playerOverlay.showInfo = false
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    
    if key = "back" then
        if m.videoNode <> invalid then
            m.videoNode.control = "stop"
        end if
        m.top.closeRequested = true
        LogInfo("VideoPlayer", "Back pressed - closing player")
        return true
    else if key = "OK" or key = "play" then
        if m.videoNode <> invalid then
            if m.videoNode.state = "playing" then
                m.videoNode.control = "pause"
                LogInfo("VideoPlayer", "Paused")
            else
                m.videoNode.control = "play"
                LogInfo("VideoPlayer", "Playing")
            end if
        end if
        ShowOverlay()
        return true
    else if key = "info" then
        if m.playerOverlay <> invalid then
            m.playerOverlay.showInfo = not m.playerOverlay.showInfo
        end if
        return true
    else if key = "left" or key = "right" then
        ' TODO: Implement channel zapping
        ShowOverlay()
        return true
    end if
    
    return false
end function
