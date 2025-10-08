sub VideoPlayerSceneInit()
    m.videoNode = m.top.FindNode("videoNode")
    m.playerOverlay = m.top.FindNode("playerOverlay")
    m.loadingBg = m.top.FindNode("loadingBg")
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.errorLabel = m.top.FindNode("errorLabel")
    
    m.top.ObserveField("channel", "VideoPlayerOnChannelChanged")
    m.videoNode.ObserveField("state", "VideoPlayerOnStateChanged")
    m.videoNode.ObserveField("position", "VideoPlayerOnPositionChanged")
    
    m.overlayTimer = invalid
    m.videoNode.setFocus(true)
end sub

sub VideoPlayerOnChannelChanged()
    channel = m.top.channel
    if channel = invalid then return
    
    ShowLoading()
    
    content = CreateObject("roSGNode", "ContentNode")
    content.title = channel.name
    content.description = channel.Lookup("group", "")
    content.url = channel.streamUrl
    
    if channel.logo <> invalid and channel.logo <> "" then
        content.hdPosterUrl = channel.logo
        content.sdPosterUrl = channel.logo
    end if
    
    ' Check for subtitle tracks if available
    if channel.DoesExist("subtitles") and channel.subtitles <> invalid then
        content.SubtitleTracks = channel.subtitles
    end if
    
    m.videoNode.content = content
    m.videoNode.control = "play"
    
    m.playerOverlay.channel = channel
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
    m.playerOverlay.showInfo = true
    
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
        m.videoNode.control = "stop"
        m.top.closeRequested = true
        return true
    else if key = "OK" or key = "play" then
        if m.videoNode.state = "playing" then
            m.videoNode.control = "pause"
        else
            m.videoNode.control = "play"
        end if
        ShowOverlay()
        return true
    else if key = "info" then
        m.playerOverlay.showInfo = not m.playerOverlay.showInfo
        return true
    else if key = "left" or key = "right" then
        ' TODO: Implement channel zapping
        ShowOverlay()
        return true
    end if
    
    return false
end function
