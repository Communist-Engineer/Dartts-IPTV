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

sub ResetSettings()
    registry = GetAppRegistry()
    registry.DeleteAll()
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
