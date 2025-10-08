sub HomeScene_init()
    m.top.ObserveField("launchArgs", "HomeScene_onLaunchArgsChanged")
    m.subtitleLabel = m.top.FindNode("subtitleLabel")
    m.titleLabel = m.top.FindNode("titleLabel")
    
    ' Show first-run legal notice
    ShowFirstRunNotice()
    
    ' Load playlists from settings
    LoadPlaylistsAndChannels()
end sub

sub HomeScene_onLaunchArgsChanged()
    args = m.top.launchArgs
    if args <> invalid and args.contentId <> invalid then
        m.subtitleLabel.text = "Deep linking to content " + args.contentId
        ' TODO: Implement deep link handling to jump to channel
    else
        m.subtitleLabel.text = "Bring your own playlists to get started"
    end if
end sub

sub ShowFirstRunNotice()
    registry = CreateObject("roRegistrySection", "dartts_iptv_settings")
    firstRun = registry.Read("first_run_complete")
    
    if firstRun = invalid or firstRun <> "true" then
        dialog = CreateObject("roSGNode", "Dialog")
        dialog.title = "Welcome to Dartt's IPTV"
        dialog.message = "Dartt's IPTV plays user-provided streams. Ensure you have rights to view any content you load. This app does not provide any streams."
        dialog.buttons = ["I Understand"]
        m.top.dialog = dialog
        
        dialog.ObserveField("buttonSelected", "OnFirstRunDialogButton")
        m.firstRunDialog = dialog
    end if
end sub

sub OnFirstRunDialogButton()
    registry = CreateObject("roRegistrySection", "dartts_iptv_settings")
    registry.Write("first_run_complete", "true")
    registry.Flush()
    
    m.top.dialog = invalid
end sub

sub LoadPlaylistsAndChannels()
    ' TODO: Load playlists from persistent settings
    ' TODO: Launch background task to fetch and parse M3U
    m.subtitleLabel.text = "Ready. Add a playlist in Settings."
end sub
