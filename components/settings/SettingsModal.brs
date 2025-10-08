' ============================================
' Logger Helper Functions (Local to Component)
' ============================================
sub LogInfo(prefix as string, message as string)
    print "[INFO] [" + prefix + "] " + message
end sub

sub LogDebug(prefix as string, message as string)
    print "[DEBUG] [" + prefix + "] " + message
end sub

sub LogWarn(prefix as string, message as string)
    print "[WARN] [" + prefix + "] " + message
end sub

sub LogError(prefix as string, message as string)
    print "[ERROR] [" + prefix + "] " + message
end sub

' ============================================
' Settings Service Functions (Local to Component)
' ============================================
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
        settings.playlists = DeserializePlaylistArray(playlistsData)
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
        registry.Write("playlists", SerializePlaylistArray(settings.playlists))
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

' Playlist serialization functions
function SerializePlaylistArray(playlists as object) as string
    if playlists = invalid or playlists.Count() = 0 then return ""
    result = ""
    for i = 0 to playlists.Count() - 1
        if i > 0 then result = result + "||"
        playlist = playlists[i]
        
        ' Handle both old string format and new object format
        if Type(playlist) = "roString" or Type(playlist) = "String" then
            ' Old format: just URL
            result = result + StrReplace(playlist, "|", "^PIPE^") + "|"
        else
            ' New format: {url: "", epgUrl: ""}
            url = ""
            epgUrl = ""
            if playlist.DoesExist("url") then url = playlist.url
            if playlist.DoesExist("epgUrl") then epgUrl = playlist.epgUrl
            result = result + StrReplace(url, "|", "^PIPE^") + "|" + StrReplace(epgUrl, "|", "^PIPE^")
        end if
    end for
    return result
end function

function DeserializePlaylistArray(data as string) as object
    if data = invalid or data = "" then return []
    parts = data.Split("||")
    result = []
    for each part in parts
        subparts = part.Split("|")
        if subparts.Count() >= 1 then
            playlist = {
                url: StrReplace(subparts[0], "^PIPE^", "|"),
                epgUrl: ""
            }
            if subparts.Count() >= 2 then
                playlist.epgUrl = StrReplace(subparts[1], "^PIPE^", "|")
            end if
            result.Push(playlist)
        end if
    end for
    return result
end function

' ============================================
' Main Init
' ============================================
sub init()
    LogInfo("SETTINGS", "Initializing Settings Modal")
    
    ' Cache node references
    m.focusIndicator = m.top.FindNode("focusIndicator")
    
    ' Option references
    m.addPlaylistOption = m.top.FindNode("addPlaylistOption")
    m.managePlistsOption = m.top.FindNode("managePlistsOption")
    m.clearCacheOption = m.top.FindNode("clearCacheOption")
    m.aboutOption = m.top.FindNode("aboutOption")
    m.closeOption = m.top.FindNode("closeOption")
    
    ' Options array for navigation
    m.options = [
        {node: m.addPlaylistOption, yPos: 120, id: "addPlaylist"},
        {node: m.managePlistsOption, yPos: 210, id: "managePlaylists"},
        {node: m.clearCacheOption, yPos: 300, id: "clearCache"},
        {node: m.aboutOption, yPos: 390, id: "about"},
        {node: m.closeOption, yPos: 480, id: "close"}
    ]
    
    m.currentIndex = 0
    SetFocusToOption(0)
    
    LogInfo("SETTINGS", "Settings Modal initialized")
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    LogDebug("SETTINGS", "Key event received: key=" + key + " press=" + FormatJSON(press))
    
    if not press then return false
    
    handled = false
    
    if key = "up" then
        if m.currentIndex > 0 then
            SetFocusToOption(m.currentIndex - 1)
        end if
        handled = true
    else if key = "down" then
        if m.currentIndex < m.options.Count() - 1 then
            SetFocusToOption(m.currentIndex + 1)
        end if
        handled = true
    else if key = "OK" then
        HandleOptionSelection()
        handled = true
    else if key = "back" then
        LogInfo("SETTINGS", "Back key pressed, closing modal")
        CloseModal()
        handled = true
    end if
    
    LogDebug("SETTINGS", "Key handled: " + FormatJSON(handled))
    return handled
end function

sub SetFocusToOption(index as integer)
    if index < 0 or index >= m.options.Count() then return
    
    m.currentIndex = index
    option = m.options[index]
    
    ' Update focus indicator position
    if m.focusIndicator <> invalid then
        m.focusIndicator.translation = [40, option.yPos]
    end if
    
    ' Set actual focus
    if option.node <> invalid then
        option.node.setFocus(true)
    end if
    
    LogDebug("SETTINGS", "Focus set to: " + option.id)
end sub

sub HandleOptionSelection()
    option = m.options[m.currentIndex]
    LogInfo("SETTINGS", "Option selected: " + option.id)
    
    if option.id = "addPlaylist" then
        ShowAddPlaylistDialog()
    else if option.id = "managePlaylists" then
        ShowManagePlaylistsDialog()
    else if option.id = "clearCache" then
        ClearCacheWithConfirmation()
    else if option.id = "about" then
        ShowAboutDialog()
    else if option.id = "close" then
        CloseModal()
    end if
end sub

sub ShowAddPlaylistDialog()
    LogInfo("SETTINGS", "Showing Add Playlist dialog")
    
    dialog = CreateObject("roSGNode", "KeyboardDialog")
    dialog.title = "Add Playlist"
    dialog.text = ""
    dialog.message = "Enter M3U playlist URL:"
    dialog.buttons = ["Add", "Cancel"]
    m.top.GetScene().dialog = dialog
    
    dialog.ObserveField("buttonSelected", "OnAddPlaylistDialogButton")
    m.addPlaylistDialog = dialog
end sub

sub OnAddPlaylistDialogButton()
    if m.addPlaylistDialog.buttonSelected = 0 then
        ' Add button pressed
        newUrl = m.addPlaylistDialog.text
        if newUrl <> invalid and newUrl <> "" then
            LogInfo("SETTINGS", "Adding new playlist URL: " + newUrl)
            
            ' Store the URL temporarily and ask for EPG URL
            m.pendingPlaylistUrl = newUrl
            ShowAddEpgDialog()
        end if
    else
        ' Cancel
        m.top.GetScene().dialog = invalid
    end if
end sub

sub ShowAddEpgDialog()
    dialog = CreateObject("roSGNode", "KeyboardDialog")
    dialog.title = "Add EPG URL (Optional)"
    dialog.text = ""
    dialog.message = "Enter XMLTV EPG URL (or leave blank):"
    dialog.buttons = ["Continue", "Skip"]
    m.top.GetScene().dialog = dialog
    
    dialog.ObserveField("buttonSelected", "OnAddEpgDialogButton")
    m.addEpgDialog = dialog
end sub

sub OnAddEpgDialogButton()
    epgUrl = ""
    if m.addEpgDialog.buttonSelected = 0 then
        ' Continue with EPG URL
        epgUrl = m.addEpgDialog.text
        if epgUrl = invalid then epgUrl = ""
    end if
    ' Skip button or empty = no EPG
    
    ' Load current settings
    settings = LoadSettings()
    
    ' Create playlist object
    newPlaylist = {
        url: m.pendingPlaylistUrl,
        epgUrl: epgUrl
    }
    
    ' Check if URL already exists
    alreadyExists = false
    for each playlist in settings.playlists
        playlistUrl = ""
        if Type(playlist) = "roAssociativeArray" and playlist.DoesExist("url") then
            playlistUrl = playlist.url
        else
            playlistUrl = playlist
        end if
        
        if playlistUrl = m.pendingPlaylistUrl then
            alreadyExists = true
            exit for
        end if
    end for
    
    if not alreadyExists then
        settings.playlists.Push(newPlaylist)
        SaveSettings(settings)
        LogInfo("SETTINGS", "Playlist added with EPG: " + epgUrl)
        
        ' Signal reload required
        m.top.reloadRequired = true
        
        ' Show success message
        ShowInfoDialog("Playlist Added", "The playlist has been added and channels will reload when you close Settings.")
    else
        ShowInfoDialog("Already Exists", "This playlist URL is already configured.")
    end if
    
    m.pendingPlaylistUrl = invalid
    m.top.GetScene().dialog = invalid
end sub

sub ShowManagePlaylistsDialog()
    LogInfo("SETTINGS", "Showing Manage Playlists dialog")
    
    settings = LoadSettings()
    
    if settings.playlists.Count() = 0 then
        ShowInfoDialog("No Playlists", "No playlists configured. Add a playlist first.")
        return
    end if
    
    ' Store playlists for management
    m.managedPlaylists = settings.playlists
    m.managePlaylistIndex = 0
    
    ' Show first playlist for management
    ShowPlaylistActionDialog()
end sub

sub ShowPlaylistActionDialog()
    if m.managedPlaylists = invalid or m.managePlaylistIndex >= m.managedPlaylists.Count() then
        ' Done managing - return to settings
        m.managedPlaylists = invalid
        m.managePlaylistIndex = 0
        return
    end if
    
    currentPlaylist = m.managedPlaylists[m.managePlaylistIndex]
    
    ' Extract URL and EPG URL
    currentUrl = ""
    currentEpgUrl = ""
    if Type(currentPlaylist) = "roAssociativeArray" then
        if currentPlaylist.DoesExist("url") then currentUrl = currentPlaylist.url
        if currentPlaylist.DoesExist("epgUrl") then currentEpgUrl = currentPlaylist.epgUrl
    else
        currentUrl = currentPlaylist
    end if
    
    ' Truncate URL for display
    displayUrl = currentUrl
    if Len(displayUrl) > 70 then
        displayUrl = Left(displayUrl, 67) + "..."
    end if
    
    message = "Playlist " + Str(m.managePlaylistIndex + 1) + " of " + Str(m.managedPlaylists.Count()) + Chr(10) + Chr(10)
    message = message + "URL: " + displayUrl + Chr(10)
    if currentEpgUrl <> "" then
        displayEpg = currentEpgUrl
        if Len(displayEpg) > 70 then
            displayEpg = Left(displayEpg, 67) + "..."
        end if
        message = message + "EPG: " + displayEpg + Chr(10)
    else
        message = message + "EPG: (none)" + Chr(10)
    end if
    message = message + Chr(10) + "What would you like to do?"
    
    dialog = CreateObject("roSGNode", "Dialog")
    dialog.title = "Manage Playlist"
    dialog.message = message
    dialog.buttons = ["Edit URL", "Edit EPG", "Delete", "Next", "Done"]
    m.top.GetScene().dialog = dialog
    
    dialog.ObserveField("buttonSelected", "OnPlaylistActionButton")
    m.playlistActionDialog = dialog
end sub

sub OnPlaylistActionButton()
    buttonIndex = m.playlistActionDialog.buttonSelected
    m.top.GetScene().dialog = invalid
    
    if buttonIndex = 0 then
        ' Edit URL
        ShowEditPlaylistUrlDialog()
    else if buttonIndex = 1 then
        ' Edit EPG
        ShowEditPlaylistEpgDialog()
    else if buttonIndex = 2 then
        ' Delete
        ConfirmDeletePlaylist()
    else if buttonIndex = 3 then
        ' Next
        m.managePlaylistIndex = m.managePlaylistIndex + 1
        if m.managePlaylistIndex >= m.managedPlaylists.Count() then
            m.managePlaylistIndex = 0
        end if
        ShowPlaylistActionDialog()
    else if buttonIndex = 4 then
        ' Done
        m.managedPlaylists = invalid
        m.managePlaylistIndex = 0
    end if
end sub

sub ShowEditPlaylistUrlDialog()
    currentPlaylist = m.managedPlaylists[m.managePlaylistIndex]
    currentUrl = ""
    if Type(currentPlaylist) = "roAssociativeArray" and currentPlaylist.DoesExist("url") then
        currentUrl = currentPlaylist.url
    else
        currentUrl = currentPlaylist
    end if
    
    dialog = CreateObject("roSGNode", "KeyboardDialog")
    dialog.title = "Edit Playlist URL"
    dialog.text = currentUrl
    dialog.message = "Edit the M3U playlist URL:"
    dialog.buttons = ["Save", "Cancel"]
    m.top.GetScene().dialog = dialog
    
    dialog.ObserveField("buttonSelected", "OnEditPlaylistUrlDialogButton")
    m.editPlaylistUrlDialog = dialog
end sub

sub OnEditPlaylistUrlDialogButton()
    if m.editPlaylistUrlDialog.buttonSelected = 0 then
        ' Save button pressed
        newUrl = m.editPlaylistUrlDialog.text
        if newUrl <> invalid and newUrl <> "" then
            LogInfo("SETTINGS", "Editing playlist URL")
            
            ' Update playlist object
            currentPlaylist = m.managedPlaylists[m.managePlaylistIndex]
            if Type(currentPlaylist) = "roAssociativeArray" then
                currentPlaylist.url = newUrl
            else
                ' Convert old string to object
                m.managedPlaylists[m.managePlaylistIndex] = {
                    url: newUrl,
                    epgUrl: ""
                }
            end if
            
            ' Save settings
            settings = LoadSettings()
            settings.playlists = m.managedPlaylists
            SaveSettings(settings)
            
            ' Signal reload required
            m.top.reloadRequired = true
            
            LogInfo("SETTINGS", "Playlist URL updated successfully")
            ShowInfoDialog("Playlist Updated", "The playlist URL has been updated. Channels will reload when you close Settings.")
        end if
    else
        ' Cancel - go back to playlist action
        ShowPlaylistActionDialog()
    end if
    
    m.top.GetScene().dialog = invalid
end sub

sub ShowEditPlaylistEpgDialog()
    currentPlaylist = m.managedPlaylists[m.managePlaylistIndex]
    currentEpgUrl = ""
    if Type(currentPlaylist) = "roAssociativeArray" and currentPlaylist.DoesExist("epgUrl") then
        currentEpgUrl = currentPlaylist.epgUrl
    end if
    
    dialog = CreateObject("roSGNode", "KeyboardDialog")
    dialog.title = "Edit EPG URL"
    dialog.text = currentEpgUrl
    dialog.message = "Edit the XMLTV EPG URL (or leave blank):"
    dialog.buttons = ["Save", "Cancel"]
    m.top.GetScene().dialog = dialog
    
    dialog.ObserveField("buttonSelected", "OnEditPlaylistEpgDialogButton")
    m.editPlaylistEpgDialog = dialog
end sub

sub OnEditPlaylistEpgDialogButton()
    if m.editPlaylistEpgDialog.buttonSelected = 0 then
        ' Save button pressed
        newEpgUrl = m.editPlaylistEpgDialog.text
        if newEpgUrl = invalid then newEpgUrl = ""
        
        LogInfo("SETTINGS", "Editing playlist EPG URL")
        
        ' Update playlist object
        currentPlaylist = m.managedPlaylists[m.managePlaylistIndex]
        if Type(currentPlaylist) = "roAssociativeArray" then
            currentPlaylist.epgUrl = newEpgUrl
        else
            ' Convert old string to object
            m.managedPlaylists[m.managePlaylistIndex] = {
                url: currentPlaylist,
                epgUrl: newEpgUrl
            }
        end if
        
        ' Save settings
        settings = LoadSettings()
        settings.playlists = m.managedPlaylists
        SaveSettings(settings)
        
        ' Signal reload required
        m.top.reloadRequired = true
        
        LogInfo("SETTINGS", "Playlist EPG URL updated successfully")
        ShowInfoDialog("EPG Updated", "The EPG URL has been updated. Channels will reload when you close Settings.")
    else
        ' Cancel - go back to playlist action
        ShowPlaylistActionDialog()
    end if
    
    m.top.GetScene().dialog = invalid
end sub

sub ConfirmDeletePlaylist()
    currentPlaylist = m.managedPlaylists[m.managePlaylistIndex]
    
    ' Extract URL for display
    currentUrl = ""
    if Type(currentPlaylist) = "roAssociativeArray" and currentPlaylist.DoesExist("url") then
        currentUrl = currentPlaylist.url
    else
        currentUrl = currentPlaylist
    end if
    
    ' Truncate URL for display
    displayUrl = currentUrl
    if Len(displayUrl) > 60 then
        displayUrl = Left(displayUrl, 57) + "..."
    end if
    
    dialog = CreateObject("roSGNode", "Dialog")
    dialog.title = "Delete Playlist"
    dialog.message = "Delete this playlist?" + Chr(10) + Chr(10) + displayUrl
    dialog.buttons = ["Delete", "Cancel"]
    m.top.GetScene().dialog = dialog
    
    dialog.ObserveField("buttonSelected", "OnDeletePlaylistConfirm")
    m.deletePlaylistDialog = dialog
end sub

sub OnDeletePlaylistConfirm()
    if m.deletePlaylistDialog.buttonSelected = 0 then
        ' Delete button pressed
        LogInfo("SETTINGS", "Deleting playlist at index: " + Str(m.managePlaylistIndex))
        
        ' Remove from array
        newPlaylists = []
        for i = 0 to m.managedPlaylists.Count() - 1
            if i <> m.managePlaylistIndex then
                newPlaylists.Push(m.managedPlaylists[i])
            end if
        end for
        
        m.managedPlaylists = newPlaylists
        
        ' Save to settings
        settings = LoadSettings()
        settings.playlists = m.managedPlaylists
        SaveSettings(settings)
        
        ' Signal reload required
        m.top.reloadRequired = true
        
        LogInfo("SETTINGS", "Playlist deleted successfully")
        
        ' Adjust index if needed
        if m.managePlaylistIndex >= m.managedPlaylists.Count() and m.managePlaylistIndex > 0 then
            m.managePlaylistIndex = m.managePlaylistIndex - 1
        end if
        
        ' Continue managing or finish
        if m.managedPlaylists.Count() > 0 then
            ShowInfoDialog("Playlist Deleted", "Playlist deleted. Channels will reload when you close Settings.")
        else
            ShowInfoDialog("All Playlists Deleted", "All playlists have been deleted. Add a new playlist to load channels.")
            m.managedPlaylists = invalid
            m.managePlaylistIndex = 0
        end if
    else
        ' Cancel - go back to playlist action
        ShowPlaylistActionDialog()
    end if
    
    m.top.GetScene().dialog = invalid
end sub

sub ClearCacheWithConfirmation()
    LogInfo("SETTINGS", "Requesting cache clear confirmation")
    
    dialog = CreateObject("roSGNode", "Dialog")
    dialog.title = "Clear Cache"
    dialog.message = "This will clear all cached channel data. Playlists will be reloaded on next launch. Continue?"
    dialog.buttons = ["Clear", "Cancel"]
    m.top.GetScene().dialog = dialog
    
    dialog.ObserveField("buttonSelected", "OnClearCacheConfirm")
    m.clearCacheDialog = dialog
end sub

sub OnClearCacheConfirm()
    if m.clearCacheDialog.buttonSelected = 0 then
        ' Clear button pressed
        LogInfo("SETTINGS", "Clearing cache")
        
        ' Clear the cache registry section
        registry = CreateObject("roRegistrySection", "dartts_iptv_cache")
        registry.DeleteAll()
        registry.Flush()
        
        LogInfo("SETTINGS", "Cache cleared successfully")
        ShowInfoDialog("Cache Cleared", "Cache has been cleared. Playlists will be reloaded when you return to Home.")
    end if
    
    m.top.GetScene().dialog = invalid
end sub

sub ShowAboutDialog()
    LogInfo("SETTINGS", "Showing About dialog")
    
    message = "Dartt's IPTV v1.0.0" + Chr(10) + Chr(10)
    message = message + "Bring your own playlists to stream IPTV content." + Chr(10) + Chr(10)
    message = message + "This app does not provide any content. Users are responsible for ensuring they have rights to view any streams they load." + Chr(10) + Chr(10)
    message = message + "For support and updates, visit:" + Chr(10)
    message = message + "github.com/Communist-Engineer/Dartts-IPTV"
    
    ShowInfoDialog("About", message)
end sub

sub ShowInfoDialog(title as string, message as string)
    dialog = CreateObject("roSGNode", "Dialog")
    dialog.title = title
    dialog.message = message
    dialog.buttons = ["OK"]
    m.top.GetScene().dialog = dialog
    
    dialog.ObserveField("buttonSelected", "OnInfoDialogButton")
    m.infoDialog = dialog
end sub

sub OnInfoDialogButton()
    m.top.GetScene().dialog = invalid
    
    ' If we were managing playlists, continue if there are more
    if m.managedPlaylists <> invalid and m.managedPlaylists.Count() > 0 then
        ShowPlaylistActionDialog()
    end if
end sub

sub CloseModal()
    LogInfo("SETTINGS", "Closing Settings Modal - signaling parent")
    
    ' Signal closure to parent (will trigger OnSettingsClosed in HomeScene)
    m.top.closed = true
    
    ' Parent will handle removal, so we don't remove ourselves here
end sub
