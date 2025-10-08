sub PlayerOverlayInit()
    m.background = m.top.FindNode("background")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.groupLabel = m.top.FindNode("groupLabel")
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
        m.titleLabel.text = channel.name
    end if

    if m.groupLabel <> invalid then
        if channel.Lookup("group") <> invalid then
            m.groupLabel.text = "Group: " + channel.group
        else
            m.groupLabel.text = ""
        end if
    end if
end sub
