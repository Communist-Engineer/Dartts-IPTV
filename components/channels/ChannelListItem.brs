sub init()
    ' Get references to UI elements
    m.background = m.top.FindNode("background")
    m.channelLogo = m.top.FindNode("channelLogo")
    m.numberBadge = m.top.FindNode("numberBadge")
    m.channelNumber = m.top.FindNode("channelNumber")
    m.channelTitle = m.top.FindNode("channelTitle")
    m.channelGroup = m.top.FindNode("channelGroup")
    
    ' Explicitly set colors to ensure visibility
    if m.channelTitle <> invalid then
        m.channelTitle.color = "0xFFFFFFFF"
    end if
    if m.channelGroup <> invalid then
        m.channelGroup.color = "0xCCCCCCFF"
    end if
    if m.channelNumber <> invalid then
        m.channelNumber.color = "0xFFFFFFFF"
    end if
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
