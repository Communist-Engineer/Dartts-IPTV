sub init()
    ' Get device display resolution
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()
    screenWidth = displaySize.w
    screenHeight = displaySize.h
    
    m.background = m.top.FindNode("background")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.groupLabel = m.top.FindNode("groupLabel")
    
    ' Update overlay elements to match screen resolution
    if m.background <> invalid then
        m.background.width = screenWidth
        m.background.height = screenHeight
    end if
    
    if m.titleLabel <> invalid then
        m.titleLabel.translation = [80, screenHeight - 160]
    end if
    
    if m.groupLabel <> invalid then
        m.groupLabel.translation = [80, screenHeight - 110]
    end if
    
    m.top.ObserveField("showInfo", "PlayerOverlayOnShowInfoChanged")
    m.top.ObserveField("channel", "PlayerOverlayOnChannelChanged")
end sub

sub PlayerOverlayOnShowInfoChanged()
    visible = m.top.showInfo
    if m.background <> invalid then m.background.visible = visible
    if m.titleLabel <> invalid then m.titleLabel.visible = visible
    if m.groupLabel <> invalid then m.groupLabel.visible = visible
end sub

sub PlayerOverlayOnChannelChanged()
    channel = m.top.channel
    if channel = invalid then return

    if m.titleLabel <> invalid then
        if channel.DoesExist("title") and channel.title <> invalid then
            m.titleLabel.text = channel.title
        else
            m.titleLabel.text = ""
        end if
    end if

    if m.groupLabel <> invalid then
        if channel.DoesExist("group") and channel.group <> invalid then
            m.groupLabel.text = "Group: " + channel.group
        else
            m.groupLabel.text = ""
        end if
    end if
end sub
