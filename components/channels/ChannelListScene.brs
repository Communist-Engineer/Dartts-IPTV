sub init()
    LogInfo("CHANNELLIST", "Initializing Channel List Scene")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.placeholderLabel = m.top.FindNode("placeholderLabel")
    m.top.ObserveField("title", "OnTitleChanged")
    m.top.ObserveField("channels", "OnChannelsChanged")
end sub

sub OnTitleChanged()
    if m.titleLabel <> invalid then
        m.titleLabel.text = m.top.title
    end if
end sub

sub OnChannelsChanged()
    ' Update placeholder based on channel count
    if m.placeholderLabel <> invalid then
        if m.top.channels <> invalid and m.top.channels.Count() > 0 then
            m.placeholderLabel.text = Str(m.top.channels.Count()) + " channels available. Channel list UI coming soon."
        else
            m.placeholderLabel.text = "No channels to display."
        end if
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    
    if key = "back" then
        ' Return to home scene
        LogInfo("CHANNELLIST", "Back pressed - returning to Home")
        ReturnToHome()
        return true
    end if
    
    return false
end function

sub ReturnToHome()
    ' Hide this scene and show home
    m.top.visible = false
    
    ' Find and show home scene
    appScene = m.top.GetScene()
    homeScene = appScene.FindNode("homeScene")
    if homeScene <> invalid then
        homeScene.visible = true
        homeScene.setFocus(true)
    end if
end sub
