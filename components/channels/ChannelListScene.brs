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
    
    ' For vertical scrolling: Create one row per channel (each row has 1 item)
    for i = 0 to m.top.channels.Count() - 1
        channel = m.top.channels[i]
        if channel <> invalid then
            ' Create a row for this channel
            row = content.CreateChild("ContentNode")
            
            ' Create the channel item as the only child of this row
            item = row.CreateChild("ContentNode")
            
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
    
    ' Set focus on the channel list after populating
    m.channelList.setFocus(true)
    
    LogInfo("CHANNELLIST", "Channel list populated with " + Str(content.getChildCount()) + " rows and focused")
end sub

sub OnChannelSelected()
    ' User selected a channel from the list
    ' For RowList, itemSelected is an array [row, col]
    itemSelectedArray = m.channelList.itemSelected
    
    if itemSelectedArray = invalid then
        LogInfo("CHANNELLIST", "itemSelected is invalid")
        return
    end if
    
    LogInfo("CHANNELLIST", "OnChannelSelected called, itemSelected type: " + Type(itemSelectedArray))
    
    ' Check if it's an array or just an integer
    rowIndex = -1
    if Type(itemSelectedArray) = "roArray" then
        if itemSelectedArray.Count() >= 1 then
            rowIndex = itemSelectedArray[0]
        end if
    else if Type(itemSelectedArray) = "roInt" or Type(itemSelectedArray) = "Integer" then
        ' Sometimes it's just an integer representing the row
        rowIndex = itemSelectedArray
    end if
    
    LogInfo("CHANNELLIST", "Row index: " + Str(rowIndex) + ", Total channels: " + Str(m.top.channels.Count()))
    
    if rowIndex >= 0 and rowIndex < m.top.channels.Count() then
        selectedChannel = m.top.channels[rowIndex]
        LogInfo("CHANNELLIST", "Channel selected: " + selectedChannel.title)
        
        ' Set the selected channel field (parent can observe this)
        m.top.selectedChannel = selectedChannel
        
        ' TODO: Navigate to video player
        PlayChannel(selectedChannel)
    else
        LogInfo("CHANNELLIST", "Invalid row index: " + Str(rowIndex))
    end if
end sub

sub PlayChannel(channel as object)
    LogInfo("CHANNELLIST", "Playing channel: " + channel.title)
    
    ' Get or create the video player scene
    appScene = m.top.GetParent()
    if appScene = invalid then
        LogError("CHANNELLIST", "Cannot get parent scene")
        return
    end if
    
    ' Find or create the video player
    videoPlayer = appScene.FindNode("videoPlayerScene")
    if videoPlayer = invalid then
        LogInfo("CHANNELLIST", "Creating new VideoPlayerScene")
        videoPlayer = CreateObject("roSGNode", "VideoPlayerScene")
        videoPlayer.id = "videoPlayerScene"
        appScene.appendChild(videoPlayer)
        
        ' Observe when player wants to close
        videoPlayer.ObserveField("closeRequested", "OnPlayerCloseRequested")
    end if
    
    ' Hide the channel list
    m.top.visible = false
    
    ' Show and start the player with the selected channel
    videoPlayer.visible = true
    videoPlayer.channel = channel
    videoPlayer.setFocus(true)
    
    LogInfo("CHANNELLIST", "Video player launched for: " + channel.title)
end sub

sub OnPlayerCloseRequested()
    ' Player wants to close - show channel list again
    appScene = m.top.GetParent()
    if appScene = invalid then return
    
    videoPlayer = appScene.FindNode("videoPlayerScene")
    if videoPlayer <> invalid then
        videoPlayer.visible = false
    end if
    
    ' Show channel list and restore focus
    m.top.visible = true
    if m.channelList <> invalid then
        m.channelList.setFocus(true)
    end if
    
    LogInfo("CHANNELLIST", "Returned from video player")
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
