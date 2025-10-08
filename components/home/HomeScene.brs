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

' ============================
' Settings Service Functions
' ============================
function GetAppRegistry() as object
    return CreateObject("roRegistrySection", "dartts_iptv_settings")
end function

function LoadSettings() as object
    registry = GetAppRegistry()
    
    settings = {
        playlists: [],
        favorites: [],
        recents: [],
        lastGroup: "",
        xmltvUrl: "",
        firstRunComplete: false,
        parentalPin: "",
        blockedGroups: [],
        timeOffsetMinutes: 0,
        clockFormat24: true,
        userAgent: "Dartts-IPTV/1.0",
        maxRedirects: 3,
        timeoutMs: 10000,
        refreshIntervalHours: 24
    }
    
    ' Load from registry
    playlistsData = registry.Read("playlists")
    if playlistsData <> invalid and playlistsData <> "" then
        settings.playlists = DeserializeArray(playlistsData)
    end if
    
    favoritesData = registry.Read("favorites")
    if favoritesData <> invalid and favoritesData <> "" then
        settings.favorites = DeserializeArray(favoritesData)
    end if
    
    recentsData = registry.Read("recents")
    if recentsData <> invalid and recentsData <> "" then
        settings.recents = DeserializeArray(recentsData)
    end if
    
    settings.lastGroup = registry.Read("last_group")
    settings.xmltvUrl = registry.Read("xmltv_url")
    settings.firstRunComplete = (registry.Read("first_run_complete") = "true")
    settings.parentalPin = registry.Read("parental_pin")
    
    blockedGroupsData = registry.Read("blocked_groups")
    if blockedGroupsData <> invalid and blockedGroupsData <> "" then
        settings.blockedGroups = DeserializeArray(blockedGroupsData)
    end if
    
    timeOffsetStr = registry.Read("time_offset_minutes")
    if timeOffsetStr <> invalid then settings.timeOffsetMinutes = Val(timeOffsetStr)
    
    clockFormat = registry.Read("clock_format_24")
    if clockFormat <> invalid then settings.clockFormat24 = (clockFormat = "true")
    
    userAgent = registry.Read("user_agent")
    if userAgent <> invalid and userAgent <> "" then settings.userAgent = userAgent
    
    return settings
end function

sub SaveSettings(settings as object)
    registry = GetAppRegistry()
    
    if settings.playlists <> invalid then
        registry.Write("playlists", SerializeArray(settings.playlists))
    end if
    
    if settings.favorites <> invalid then
        registry.Write("favorites", SerializeArray(settings.favorites))
    end if
    
    if settings.recents <> invalid then
        registry.Write("recents", SerializeArray(settings.recents))
    end if
    
    if settings.lastGroup <> invalid then
        registry.Write("last_group", settings.lastGroup)
    end if
    
    if settings.xmltvUrl <> invalid then
        registry.Write("xmltv_url", settings.xmltvUrl)
    end if
    
    if settings.firstRunComplete <> invalid then
        registry.Write("first_run_complete", BoolToString(settings.firstRunComplete))
    end if
    
    if settings.parentalPin <> invalid then
        registry.Write("parental_pin", settings.parentalPin)
    end if
    
    if settings.blockedGroups <> invalid then
        registry.Write("blocked_groups", SerializeArray(settings.blockedGroups))
    end if
    
    if settings.timeOffsetMinutes <> invalid then
        registry.Write("time_offset_minutes", Str(settings.timeOffsetMinutes))
    end if
    
    if settings.clockFormat24 <> invalid then
        registry.Write("clock_format_24", BoolToString(settings.clockFormat24))
    end if
    
    if settings.userAgent <> invalid then
        registry.Write("user_agent", settings.userAgent)
    end if
    
    registry.Flush()
end sub

function SerializeArray(arr as object) as string
    if arr = invalid or arr.Count() = 0 then return ""
    result = ""
    for i = 0 to arr.Count() - 1
        if i > 0 then result = result + "|"
        result = result + StrReplace(arr[i], "|", "^PIPE^")
    end for
    return result
end function

function DeserializeArray(data as string) as object
    if data = invalid or data = "" then return []
    parts = data.Split("|")
    result = []
    for each part in parts
        result.Push(StrReplace(part, "^PIPE^", "|"))
    end for
    return result
end function

function BoolToString(value as boolean) as string
    if value then return "true"
    return "false"
end function

function StrReplace(source as string, find as string, replace as string) as string
    return source.Replace(find, replace)
end function

' ============================
' Component Initialization
' ============================
sub init()
    LogInfo("HOME", "Initializing Home Scene")
    
    ' Cache node references for performance
    m.title = m.top.FindNode("title")
    m.subtitle = m.top.FindNode("subtitle")
    m.errorBanner = m.top.FindNode("errorBanner")
    m.errorMessage = m.top.FindNode("errorMessage")
    m.loadingIndicator = invalid
    m.focusIndicator = invalid
    
    ' Log component info
    LogInfo("HOME", "Component type: " + m.top.subtype())
    childCount = m.top.getChildCount()
    LogInfo("HOME", "Component child count: " + FormatJson(childCount))
    
    ' Log what children exist
    for i = 0 to childCount - 1
        child = m.top.getChild(i)
        if child <> invalid then
            LogInfo("HOME", "Child " + FormatJson(i) + ": " + child.subtype() + " id=" + FormatJson(child.id))
        end if
    end for
    
    ' Find UI elements
    m.title = m.top.FindNode("title")
    m.subtitle = m.top.FindNode("subtitle")
    m.errorBanner = m.top.FindNode("errorBanner")
    m.errorMessage = m.top.FindNode("errorMessage")
    m.loadingIndicator = m.top.FindNode("loadingIndicator")
    m.focusIndicator = m.top.FindNode("focusIndicator")
    
    LogInfo("HOME", "Title found: " + FormatJson(m.title <> invalid) + ", subtitle found: " + FormatJson(m.subtitle <> invalid))
    
    ' Try to find buttons directly first
    m.addPlaylistButton = m.top.FindNode("addPlaylistButton")
    m.playlistsButton = m.top.FindNode("playlistsButton")
    m.allChannelsButton = m.top.FindNode("allChannelsButton")
    m.groupsButton = m.top.FindNode("groupsButton")
    m.favoritesButton = m.top.FindNode("favoritesButton")
    m.recentsButton = m.top.FindNode("recentsButton")
    m.guideButton = m.top.FindNode("guideButton")
    m.settingsButton = m.top.FindNode("settingsButton")
    
    LogInfo("HOME", "Direct button search - addPlaylist: " + FormatJson(m.addPlaylistButton <> invalid) + ", playlists: " + FormatJson(m.playlistsButton <> invalid))
    
    ' Find menu container first
    menuContainer = m.top.FindNode("menuContainer")
    LogInfo("HOME", "menuContainer found: " + FormatJson(menuContainer <> invalid))
    
    if menuContainer <> invalid then
        childCount = menuContainer.getChildCount()
        LogInfo("HOME", "menuContainer has " + FormatJson(childCount) + " children")
    end if
    
    ' Use direct button references if found
    if m.addPlaylistButton = invalid then
        LogWarn("HOME", "Buttons not found directly, trying menuContainer search")
        if menuContainer <> invalid then
            m.addPlaylistButton = menuContainer.FindNode("addPlaylistButton")
            m.playlistsButton = menuContainer.FindNode("playlistsButton")
            m.allChannelsButton = menuContainer.FindNode("allChannelsButton")
            m.groupsButton = menuContainer.FindNode("groupsButton")
            m.favoritesButton = menuContainer.FindNode("favoritesButton")
            m.recentsButton = menuContainer.FindNode("recentsButton")
            m.guideButton = menuContainer.FindNode("guideButton")
            m.settingsButton = menuContainer.FindNode("settingsButton")
            
            LogInfo("HOME", "menuContainer search - addPlaylist: " + FormatJson(m.addPlaylistButton <> invalid))
        end if
    end if
    
    ' Count labels (nested inside buttons)
    if m.playlistsButton <> invalid then m.playlistsCount = m.playlistsButton.FindNode("playlistsCount")
    if m.allChannelsButton <> invalid then m.allChannelsCount = m.allChannelsButton.FindNode("allChannelsCount")
    if m.groupsButton <> invalid then m.groupsCount = m.groupsButton.FindNode("groupsCount")
    if m.favoritesButton <> invalid then m.favoritesCount = m.favoritesButton.FindNode("favoritesCount")
    if m.recentsButton <> invalid then m.recentsCount = m.recentsButton.FindNode("recentsCount")
    
    ' Menu items array for navigation
    m.menuItems = [
        {button: m.addPlaylistButton, row: 0, col: 0, id: "addPlaylist"},
        {button: m.playlistsButton, row: 0, col: 1, id: "playlists"},
        {button: m.allChannelsButton, row: 0, col: 2, id: "allChannels"},
        {button: m.groupsButton, row: 0, col: 3, id: "groups"},
        {button: m.favoritesButton, row: 1, col: 0, id: "favorites"},
        {button: m.recentsButton, row: 1, col: 1, id: "recents"},
        {button: m.guideButton, row: 1, col: 2, id: "guide"},
        {button: m.settingsButton, row: 1, col: 3, id: "settings"}
    ]
    
    ' State management
    m.currentFocusIndex = 0
    m.channels = []
    m.groups = {}
    m.settings = invalid
    m.isLoading = false
    
    ' Observe launch args for deep linking
    m.top.ObserveField("launchArgs", "onLaunchArgsChanged")
    
    ' Show first-run legal notice
    ShowFirstRunNotice()
    
    ' Load settings and initialize
    LoadSettingsAndCache()
    
    ' Set initial focus
    SetFocusToMenuItem(0)
    
    LogInfo("HOME", "Home Scene initialized")
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    
    ' Don't handle keys if we're not visible
    if not m.top.visible then return false
    
    handled = false
    
    if key = "left" then
        NavigateLeft()
        handled = true
    else if key = "right" then
        NavigateRight()
        handled = true
    else if key = "up" then
        NavigateUp()
        handled = true
    else if key = "down" then
        NavigateDown()
        handled = true
    else if key = "OK" then
        HandleMenuSelection()
        handled = true
    else if key = "back" then
        ' On Home screen, back should exit the app
        ' Return false to allow default behavior (exit)
        LogInfo("HOME", "Back pressed on Home - exiting app")
        handled = false
    end if
    
    return handled
end function

sub NavigateLeft()
    currentItem = m.menuItems[m.currentFocusIndex]
    if currentItem.col > 0 then
        ' Move left in same row
        newIndex = FindMenuItemIndex(currentItem.row, currentItem.col - 1)
        if newIndex >= 0 then
            SetFocusToMenuItem(newIndex)
        end if
    else
        ' Wrap to end of row
        newIndex = FindMenuItemIndex(currentItem.row, 3)
        if newIndex >= 0 then
            SetFocusToMenuItem(newIndex)
        end if
    end if
end sub

sub NavigateRight()
    currentItem = m.menuItems[m.currentFocusIndex]
    if currentItem.col < 3 then
        ' Move right in same row
        newIndex = FindMenuItemIndex(currentItem.row, currentItem.col + 1)
        if newIndex >= 0 then
            SetFocusToMenuItem(newIndex)
        end if
    else
        ' Wrap to start of row
        newIndex = FindMenuItemIndex(currentItem.row, 0)
        if newIndex >= 0 then
            SetFocusToMenuItem(newIndex)
        end if
    end if
end sub

sub NavigateUp()
    currentItem = m.menuItems[m.currentFocusIndex]
    if currentItem.row > 0 then
        ' Move up
        newIndex = FindMenuItemIndex(currentItem.row - 1, currentItem.col)
        if newIndex >= 0 then
            SetFocusToMenuItem(newIndex)
        end if
    end if
end sub

sub NavigateDown()
    currentItem = m.menuItems[m.currentFocusIndex]
    if currentItem.row < 1 then
        ' Move down
        newIndex = FindMenuItemIndex(currentItem.row + 1, currentItem.col)
        if newIndex >= 0 then
            SetFocusToMenuItem(newIndex)
        end if
    end if
end sub

function FindMenuItemIndex(row as integer, col as integer) as integer
    for i = 0 to m.menuItems.Count() - 1
        item = m.menuItems[i]
        if item.row = row and item.col = col then
            return i
        end if
    end for
    return -1
end function

sub SetFocusToMenuItem(index as integer)
    if index < 0 or index >= m.menuItems.Count() then return
    
    m.currentFocusIndex = index
    item = m.menuItems[index]
    
    ' Skip if button is invalid
    if item.button = invalid then return
    
    ' Update focus indicator position
    if m.focusIndicator <> invalid then
        xPos = 60 + (item.col * 430)
        yPos = 280 + (item.row * 230)
        m.focusIndicator.translation = [xPos, yPos]
    end if
    
    ' Set actual focus
    item.button.setFocus(true)
    
    LogDebug("HOME", "Focus set to: " + item.id)
end sub

sub HandleMenuSelection()
    item = m.menuItems[m.currentFocusIndex]
    if item = invalid or item.button = invalid then return
    
    LogInfo("HOME", "Menu item selected: " + item.id)
    
    if item.id = "addPlaylist" then
        OpenAddPlaylist()
    else if item.id = "playlists" then
        OpenPlaylists()
    else if item.id = "allChannels" then
        OpenAllChannels()
    else if item.id = "groups" then
        OpenGroups()
    else if item.id = "favorites" then
        OpenFavorites()
    else if item.id = "recents" then
        OpenRecents()
    else if item.id = "guide" then
        OpenGuide()
    else if item.id = "settings" then
        OpenSettings()
    end if
end sub

sub onLaunchArgsChanged()
    args = m.top.launchArgs
    if args <> invalid and args.contentId <> invalid then
        LogInfo("HOME", "Deep link detected: contentId=" + args.contentId)
        if m.subtitle <> invalid then m.subtitle.text = "Launching channel: " + args.contentId
        ' Handle deep link after cache/settings load
        HandleDeepLink(args)
    end if
end sub

sub ShowFirstRunNotice()
    registry = CreateObject("roRegistrySection", "dartts_iptv_settings")
    firstRun = registry.Read("first_run_complete")
    
    if firstRun = invalid or firstRun <> "true" then
        LogInfo("HOME", "First run detected - showing legal notice")
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
    LogInfo("HOME", "First run notice acknowledged")
    registry = CreateObject("roRegistrySection", "dartts_iptv_settings")
    registry.Write("first_run_complete", "true")
    registry.Flush()
    
    m.top.dialog = invalid
end sub

sub LoadSettingsAndCache()
    LogInfo("HOME", "Loading settings and cache")
    
    ' Load settings using SettingsService
    m.settings = LoadSettings()
    
    ' Try to load cached data first for instant display
    cachedData = LoadCachedChannelData()
    if cachedData <> invalid and cachedData.channels <> invalid then
        LogInfo("HOME", "Using cached channel data: " + Str(cachedData.channels.Count()) + " channels")
        m.channels = cachedData.channels
        m.groups = cachedData.groups
        UpdateUI()
    else
        LogInfo("HOME", "No cached data available")
        ShowSkeletonState()
    end if
    
    ' Start background loading if playlists are configured
    if m.settings.playlists.Count() > 0 then
        LoadPlaylistsInBackground()
    else
        ShowFirstRunState()
    end if
end sub

sub ShowSkeletonState()
    LogInfo("HOME", "Showing skeleton/loading state")
    if m.subtitle <> invalid then m.subtitle.text = "Loading playlists..."
    if m.loadingIndicator <> invalid then m.loadingIndicator.visible = true
    
    ' Show placeholder counts
    if m.playlistsCount <> invalid then m.playlistsCount.text = "Loading..."
    if m.allChannelsCount <> invalid then m.allChannelsCount.text = "Loading..."
    if m.groupsCount <> invalid then m.groupsCount.text = "Loading..."
    if m.favoritesCount <> invalid then m.favoritesCount.text = Str(m.settings.favorites.Count()) + " favorites"
    if m.recentsCount <> invalid then m.recentsCount.text = Str(m.settings.recents.Count()) + " recent"
end sub

sub ShowFirstRunState()
    LogInfo("HOME", "Showing first-run state (no playlists)")
    if m.subtitle <> invalid then m.subtitle.text = "Get started by adding a playlist"
    if m.loadingIndicator <> invalid then m.loadingIndicator.visible = false
    
    ' Update counts
    if m.playlistsCount <> invalid then m.playlistsCount.text = "0 configured"
    if m.allChannelsCount <> invalid then m.allChannelsCount.text = "0 channels"
    if m.groupsCount <> invalid then m.groupsCount.text = "0 groups"
    if m.favoritesCount <> invalid then m.favoritesCount.text = "0 favorites"
    if m.recentsCount <> invalid then m.recentsCount.text = "0 recent"
    
    ' Ensure Add Playlist is focused
    SetFocusToMenuItem(0)
end sub

sub LoadPlaylistsInBackground()
    LogInfo("HOME", "Starting background playlist load")
    m.isLoading = true
    
    ' Create and configure the loader task
    m.loaderTask = CreateObject("roSGNode", "PlaylistLoaderTask")
    if m.loaderTask = invalid then
        LogError("HOME", "Failed to create PlaylistLoaderTask")
        ShowError("Failed to initialize playlist loader", false)
        m.isLoading = false
        return
    end if
    
    m.loaderTask.playlistUrls = m.settings.playlists
    
    ' Observe task completion
    m.loaderTask.ObserveField("status", "OnPlaylistLoadComplete")
    
    ' Run the task
    m.loaderTask.control = "RUN"
end sub

sub OnPlaylistLoadComplete()
    status = m.loaderTask.status
    LogInfo("HOME", "Playlist load completed with status: " + status)
    
    m.isLoading = false
    if m.loadingIndicator <> invalid then m.loadingIndicator.visible = false
    
    if status = "complete" or status = "partial" then
        result = m.loaderTask.result
        
        if result.channels <> invalid and result.channels.Count() > 0 then
            m.channels = result.channels
            m.groups = result.groups
            
            ' Save to cache for next time
            SaveCachedChannelData({
                channels: m.channels,
                groups: m.groups
            })
            
            UpdateUI()
            if m.subtitle <> invalid then m.subtitle.text = "Ready - " + Str(m.channels.Count()) + " channels loaded"
            
            ' Show partial error if any
            if status = "partial" and result.errors.Count() > 0 then
                ShowError(result.errors[0], true)
            end if
        else
            ShowError("No channels found in playlists", true)
        end if
    else if status = "error" then
        result = m.loaderTask.result
        errorMsg = "Failed to load playlists"
        if result <> invalid and result.errors <> invalid and result.errors.Count() > 0 then
            errorMsg = result.errors[0]
        end if
        ShowError(errorMsg, true)
    end if
end sub

sub UpdateUI()
    ' Update all counts based on loaded data
    if m.playlistsCount <> invalid then m.playlistsCount.text = Str(m.settings.playlists.Count()) + " configured"
    if m.allChannelsCount <> invalid then m.allChannelsCount.text = Str(m.channels.Count()) + " channels"
    
    ' Count groups
    groupCount = 0
    if m.groups <> invalid then
        for each groupKey in m.groups
            if groupKey <> invalid then groupCount = groupCount + 1
        end for
    end if
    if m.groupsCount <> invalid then m.groupsCount.text = Str(groupCount) + " groups"
    
    ' Update favorites and recents
    if m.favoritesCount <> invalid then m.favoritesCount.text = Str(m.settings.favorites.Count()) + " favorites"
    if m.recentsCount <> invalid then m.recentsCount.text = Str(m.settings.recents.Count()) + " recent"
    
    LogDebug("HOME", "UI updated with current data")
end sub

sub ShowError(message as string, showRetry as boolean)
    LogError("HOME", "Showing error: " + message)
    
    if showRetry then
        m.errorMessage.text = message + " - Press OK to retry"
    else
        m.errorMessage.text = message
    end if
    
    m.errorBanner.visible = true
    if m.subtitle <> invalid then m.subtitle.text = "Error loading playlists"
    
    ' Auto-hide after 5 seconds if no retry
    if not showRetry then
        m.errorTimer = CreateObject("roSGNode", "Timer")
        m.errorTimer.duration = 5
        m.errorTimer.repeat = false
        m.errorTimer.ObserveField("fire", "HideError")
        m.errorTimer.control = "start"
    end if
end sub

sub HideError()
    m.errorBanner.visible = false
end sub

sub RetryLoad()
    LogInfo("HOME", "Retrying playlist load")
    HideError()
    LoadPlaylistsInBackground()
end sub

' Navigation functions
sub OpenAddPlaylist()
    LogInfo("HOME", "Opening Add Playlist")
    ShowAddPlaylistDialog()
end sub

sub ShowAddPlaylistDialog()
    dialog = CreateObject("roSGNode", "KeyboardDialog")
    dialog.title = "Add Playlist"
    dialog.text = ""
    dialog.message = "Enter M3U playlist URL:"
    dialog.buttons = ["Add", "Cancel"]
    m.top.dialog = dialog
    
    dialog.ObserveField("buttonSelected", "OnAddPlaylistDialogButton")
    m.addPlaylistDialog = dialog
end sub

sub OnAddPlaylistDialogButton()
    if m.addPlaylistDialog.buttonSelected = 0 then
        ' Add button pressed
        newUrl = m.addPlaylistDialog.text
        if newUrl <> invalid and newUrl <> "" then
            LogInfo("HOME", "Adding new playlist: " + newUrl)
            
            ' Add to settings
            m.settings.playlists.Push(newUrl)
            SaveSettings(m.settings)
            
            ' Reload playlists immediately
            if m.subtitle <> invalid then m.subtitle.text = "Loading new playlist..."
            LoadPlaylistsInBackground()
        end if
    end if
    
    m.top.dialog = invalid
end sub

sub OpenPlaylists()
    LogInfo("HOME", "Opening Playlists management")
    ' For now, show the settings which includes playlist management
    OpenSettings()
end sub

sub OpenAllChannels()
    if m.channels.Count() = 0 then
        ShowError("No channels available. Add a playlist first.", false)
        return
    end if
    
    LogInfo("HOME", "Opening All Channels view")
    ShowChannelList(m.channels, "All Channels")
end sub

sub OpenGroups()
    if m.groups = invalid or m.groups.Count() = 0 then
        ShowError("No groups available.", false)
        return
    end if
    
    LogInfo("HOME", "Opening Groups view")
    ' TODO: Implement group selection screen
    ' For now, show first group's channels
    for each groupName in m.groups
        ShowChannelList(m.groups[groupName], "Group: " + groupName)
        exit for
    end for
end sub

sub OpenFavorites()
    if m.settings.favorites.Count() = 0 then
        ShowError("No favorites yet. Add favorites by selecting channels.", false)
        return
    end if
    
    LogInfo("HOME", "Opening Favorites view")
    
    ' Filter channels to favorites only
    favoriteChannels = []
    for each channel in m.channels
        for each favId in m.settings.favorites
            if channel.id = favId then
                favoriteChannels.Push(channel)
                exit for
            end if
        end for
    end for
    
    ShowChannelList(favoriteChannels, "Favorites")
end sub

sub OpenRecents()
    if m.settings.recents.Count() = 0 then
        ShowError("No recent channels. Recently watched channels will appear here.", false)
        return
    end if
    
    LogInfo("HOME", "Opening Recents view")
    
    ' Filter channels to recents only
    recentChannels = []
    for each recentId in m.settings.recents
        for each channel in m.channels
            if channel.id = recentId then
                recentChannels.Push(channel)
                exit for
            end if
        end for
    end for
    
    ShowChannelList(recentChannels, "Recently Watched")
end sub

sub OpenGuide()
    LogInfo("HOME", "Opening Guide view")
    ShowError("Guide feature coming soon. EPG support will be added in a future update.", false)
    ' TODO: Implement EPG guide view
end sub

sub OpenSettings()
    LogInfo("HOME", "Opening Settings")
    ShowSettingsModal()
end sub

sub ShowChannelList(channels as object, title as string)
    LogInfo("HOME", "Showing channel list: " + title + " with " + Str(channels.Count()) + " channels")
    
    ' Get or create channel list scene
    appScene = m.top.GetScene()
    channelList = appScene.FindNode("channelListScene")
    
    if channelList = invalid then
        LogInfo("HOME", "Creating new ChannelListScene")
        channelList = CreateObject("roSGNode", "ChannelListScene")
        channelList.id = "channelListScene"
        channelList.visible = false
        appScene.appendChild(channelList)
    end if
    
    ' Set data
    channelList.channels = channels
    channelList.title = title
    
    ' Hide home scene and show channel list
    m.top.visible = false
    channelList.visible = true
    channelList.setFocus(true)
    
    LogInfo("HOME", "Channel list scene shown and focused")
end sub

sub ShowSettingsModal()
    ' Create settings modal
    settingsModal = CreateObject("roSGNode", "SettingsModal")
    if settingsModal = invalid then
        ShowError("Settings not yet implemented", false)
        return
    end if
    
    settingsModal.id = "settingsModal"
    m.top.appendChild(settingsModal)
    settingsModal.ObserveField("closed", "OnSettingsClosed")
    
    ' Give focus to the modal so it receives key events
    settingsModal.setFocus(true)
    
    ' Store reference to modal
    m.settingsModal = settingsModal
    
    LogInfo("HOME", "Settings modal opened and focused")
end sub

sub OnSettingsClosed()
    LogInfo("HOME", "OnSettingsClosed called")
    
    ' Check if reload is required
    needsReload = false
    if m.settingsModal <> invalid and m.settingsModal.reloadRequired = true then
        needsReload = true
        LogInfo("HOME", "Settings modal signaled reload required")
    end if
    
    ' Remove the modal from scene
    if m.settingsModal <> invalid then
        m.top.removeChild(m.settingsModal)
        m.settingsModal = invalid
    end if
    
    ' Return focus to home scene - use nested checks to avoid invalid comparisons
    if m.menuItems <> invalid and m.menuItems.Count() > 0 then
        if m.currentFocusIndex <> invalid then
            if m.currentFocusIndex >= 0 and m.currentFocusIndex < m.menuItems.Count() then
                item = m.menuItems[m.currentFocusIndex]
                if item <> invalid and item.button <> invalid then
                    item.button.setFocus(true)
                    LogInfo("HOME", "Focus returned to menu item: " + FormatJSON(m.currentFocusIndex))
                end if
            end if
        else
            LogWarn("HOME", "Could not return focus - m.currentFocusIndex is invalid")
        end if
    else
        LogWarn("HOME", "Could not return focus - m.menuItems is invalid")
    end if
    
    ' Reload settings after modal closes
    m.settings = LoadSettings()
    LogInfo("HOME", "Settings closed, settings reloaded")
    
    ' Reload channels if required
    if needsReload then
        LogInfo("HOME", "Reloading channels after settings change")
        if m.subtitle <> invalid then m.subtitle.text = "Reloading playlists..."
        LoadPlaylistsInBackground()
    end if
end sub

sub HandleDeepLink(args as object)
    ' Handle deep link to content
    LogInfo("HOME", "Handling deep link")
    
    if args.contentId = invalid or m.channels.Count() = 0 then
        LogWarn("HOME", "Cannot handle deep link - no channels loaded")
        return
    end if
    
    ' Find channel by contentId
    targetChannel = invalid
    for each channel in m.channels
        if channel.id = args.contentId then
            targetChannel = channel
            exit for
        end if
    end for
    
    if targetChannel <> invalid then
        LogInfo("HOME", "Deep linking to channel: " + targetChannel.name)
        ' TODO: Open video player with this channel
        if m.subtitle <> invalid then m.subtitle.text = "Playing: " + targetChannel.name
    else
        LogWarn("HOME", "Deep link channel not found: " + args.contentId)
        if m.subtitle <> invalid then m.subtitle.text = "Channel not found: " + args.contentId
    end if
end sub

' Cache management functions
function LoadCachedChannelData() as dynamic
    registry = CreateObject("roRegistrySection", "dartts_iptv_cache")
    
    channelsData = registry.Read("channels")
    ' groupsData = registry.Read("groups") ' TODO: Use when implementing cache deserialization
    
    if channelsData = invalid or channelsData = "" then
        return invalid
    end if
    
    ' Deserialize channel data (simplified - in production use proper serialization)
    ' For now, return invalid to force fresh load
    ' TODO: Implement proper cache serialization
    return invalid
end function

sub SaveCachedChannelData(cacheData as object)
    ' TODO: Implement proper cache serialization
    ' For now, just log the count
    if cacheData <> invalid and cacheData.channels <> invalid then
        LogInfo("HOME", "Cache save requested for " + Str(cacheData.channels.Count()) + " channels (not yet fully implemented)")
    else
        LogInfo("HOME", "Cache save requested with invalid data")
    end if
    ' When implemented, serialize cacheData.channels and cacheData.groups to registry
end sub
