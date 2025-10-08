sub init()
    ' Get references to UI elements
    m.background = m.top.FindNode("background")
    m.focusIndicator = m.top.FindNode("focusIndicator")
    m.channelLogo = m.top.FindNode("channelLogo")
    m.numberBadge = m.top.FindNode("numberBadge")
    m.channelNumber = m.top.FindNode("channelNumber")
    m.channelTitle = m.top.FindNode("channelTitle")
    m.channelGroup = m.top.FindNode("channelGroup")
end sub

sub OnContentChanged()
    ' Update the list item when content changes
    content = m.top.itemContent
    
    if content = invalid then return
    
    ' Set channel title
    if content.title <> invalid then
        m.channelTitle.text = content.title
    end if
    
    ' Set channel group/category
    if content.description <> invalid and content.description <> "" then
        m.channelGroup.text = content.description
    else
        m.channelGroup.text = "Uncategorized"
    end if
    
    ' Set channel number (from index)
    if content.channelIndex <> invalid then
        m.channelNumber.text = Str(content.channelIndex + 1)
    end if
    
    ' Set channel logo if available
    if content.hdPosterUrl <> invalid and content.hdPosterUrl <> "" then
        m.channelLogo.uri = content.hdPosterUrl
        m.channelLogo.visible = true
        m.numberBadge.visible = false
    else
        m.channelLogo.visible = false
        m.numberBadge.visible = true
    end if
end sub

sub OnFocusPercentChanged()
    ' Animate focus indicator based on focus percentage (0.0 to 1.0)
    focusPercent = m.top.focusPercent
    
    ' Fade in/out the focus indicator
    m.focusIndicator.opacity = focusPercent * 0.5
    
    ' Slightly scale the background when focused
    if focusPercent > 0.5 then
        m.background.color = "0x2A2A2AFF"
    else
        m.background.color = "0x1A1A1AFF"
    end if
end sub
