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
            LogInfo("SETTINGS", "Adding new playlist: " + newUrl)
            
            ' Load current settings
            settings = LoadSettings()
            
            ' Check if already exists
            alreadyExists = false
            for each url in settings.playlists
                if url = newUrl then
                    alreadyExists = true
                    exit for
                end if
            end for
            
            if not alreadyExists then
                settings.playlists.Push(newUrl)
                SaveSettings(settings)
                LogInfo("SETTINGS", "Playlist added successfully")
                
                ' Show success message
                ShowInfoDialog("Playlist Added", "The playlist has been added and will be loaded on return to Home.")
            else
                ShowInfoDialog("Already Exists", "This playlist URL is already configured.")
            end if
        end if
    end if
    
    m.top.GetScene().dialog = invalid
end sub

sub ShowManagePlaylistsDialog()
    LogInfo("SETTINGS", "Showing Manage Playlists dialog")
    
    settings = LoadSettings()
    
    if settings.playlists.Count() = 0 then
        ShowInfoDialog("No Playlists", "No playlists configured. Add a playlist first.")
        return
    end if
    
    ' Build message with playlist list
    message = "Configured playlists:" + Chr(10) + Chr(10)
    for i = 0 to settings.playlists.Count() - 1
        message = message + Str(i + 1) + ". " + settings.playlists[i] + Chr(10)
    end for
    message = message + Chr(10) + "Use Settings on device to remove playlists."
    
    ShowInfoDialog("Manage Playlists", message)
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
end sub

sub CloseModal()
    LogInfo("SETTINGS", "Closing Settings Modal - signaling parent")
    
    ' Signal closure to parent (will trigger OnSettingsClosed in HomeScene)
    m.top.closed = true
    
    ' Parent will handle removal, so we don't remove ourselves here
end sub
