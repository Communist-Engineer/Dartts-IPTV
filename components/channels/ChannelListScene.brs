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
    LogInfo("CHANNELLIST", "Initializing Channel List Scene")
    
    ' Find UI elements
    m.titleLabel = m.top.FindNode("titleLabel")
    m.helpLabel = m.top.FindNode("helpLabel")
    m.channelList = m.top.FindNode("channelList")
    m.emptyMessage = m.top.FindNode("emptyMessage")
    
    ' Set up channel list
    if m.channelList <> invalid then
        m.channelList.SetFocus(true)
        m.channelList.ObserveField("itemSelected", "OnChannelSelected")
        
        ' Set up the content descriptor for the list
        m.channelList.itemComponentName = "ChannelListItem"
    end if
    
    ' Observe field changes
    m.top.ObserveField("title", "OnTitleChanged")
    m.top.ObserveField("channels", "OnChannelsChanged")
    
    LogInfo("CHANNELLIST", "Channel List Scene initialized")
end sub

sub OnTitleChanged()
    if m.titleLabel <> invalid and m.top.title <> invalid then
        m.titleLabel.text = m.top.title
        LogInfo("CHANNELLIST", "Title set to: " + m.top.title)
    end if
end sub

sub OnChannelsChanged()
    LogInfo("CHANNELLIST", "Channels updated")
    
    if m.top.channels = invalid or m.top.channels.Count() = 0 then
        ' No channels - show empty message
        if m.channelList <> invalid then m.channelList.visible = false
        if m.emptyMessage <> invalid then m.emptyMessage.visible = true
        LogWarn("CHANNELLIST", "No channels to display")
        return
    end if
    
    ' We have channels - populate the list
    channelCount = m.top.channels.Count()
    LogInfo("CHANNELLIST", "Populating list with " + Str(channelCount) + " channels")
    
    ' Hide empty message, show list
    if m.emptyMessage <> invalid then m.emptyMessage.visible = false
    if m.channelList <> invalid then 
        m.channelList.visible = true
        PopulateChannelList()
    end if
end sub

sub PopulateChannelList()
    ' Create content node for the list
    content = CreateObject("roSGNode", "ContentNode")
    
    ' Add each channel as a child content node
    for i = 0 to m.top.channels.Count() - 1
        channel = m.top.channels[i]
        if channel <> invalid then
            item = content.CreateChild("ContentNode")
            
            ' Set standard ContentNode fields
            if channel.title <> invalid then item.title = channel.title
            if channel.group <> invalid then item.description = channel.group
            if channel.logo <> invalid then item.hdPosterUrl = channel.logo
            
            ' Add custom fields using addFields
            item.addFields({
                streamUrl: channel.streamUrl,
                channelIndex: i,
                channelId: channel.id,
                tvgId: channel.tvgId
            })
        end if
    end for
    
    ' Set the content on the list
    m.channelList.content = content
    
    LogInfo("CHANNELLIST", "Channel list populated with " + Str(content.getChildCount()) + " items")
end sub

sub OnChannelSelected()
    ' User selected a channel from the list
    selectedIndex = m.channelList.itemSelected
    
    if selectedIndex >= 0 and selectedIndex < m.top.channels.Count() then
        selectedChannel = m.top.channels[selectedIndex]
        LogInfo("CHANNELLIST", "Channel selected: " + selectedChannel.title)
        
        ' Set the selected channel field (parent can observe this)
        m.top.selectedChannel = selectedChannel
        
        ' TODO: Navigate to video player
        PlayChannel(selectedChannel)
    end if
end sub

sub PlayChannel(channel as object)
    LogInfo("CHANNELLIST", "Playing channel: " + channel.title)
    
    ' TODO: Implement video player navigation
    ' For now, just show a message
    dialog = CreateObject("roSGNode", "Dialog")
    dialog.title = "Play Channel"
    dialog.message = "Now playing: " + channel.title + Chr(10) + "Stream: " + channel.streamUrl
    dialog.buttons = ["OK"]
    m.top.GetScene().dialog = dialog
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
