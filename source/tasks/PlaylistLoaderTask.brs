sub PlaylistLoaderTaskRun()
    m.top.status = "loading"
    m.top.result = {
        channels: [],
        groups: CreateObject("roAssociativeArray"),
        errors: []
    }
    
    urls = m.top.playlistUrls
    if urls = invalid or urls.Count() = 0 then
        m.top.result.errors.Push("No playlist URLs provided")
        m.top.status = "error"
        return
    end if
    
    allChannels = []
    allGroups = CreateObject("roAssociativeArray")
    allErrors = []
    
    for each url in urls
        LogInfo("PlaylistLoader", "Fetching playlist: " + url)
        
        response = FetchTextResource(url, {
            timeout: 15000,
            retries: 2,
            userAgent: "Dartts-IPTV/1.0"
        })
        
        if response.success then
            LogInfo("PlaylistLoader", "Parsing M3U content")
            parsed = ParseM3U(response.body)
            
            if parsed.errors.Count() > 0 then
                for each err in parsed.errors
                    allErrors.Push("URL " + url + ": " + err)
                end for
            end if
            
            for each channel in parsed.channels
                allChannels.Push(channel)
            end for
            
            for each groupKey in parsed.groups
                if not allGroups.DoesExist(groupKey) then
                    allGroups[groupKey] = []
                end if
                for each ch in parsed.groups[groupKey]
                    allGroups[groupKey].Push(ch)
                end for
            end for
        else
            errorMsg = "Failed to fetch " + url
            if response.error <> invalid then
                errorMsg = errorMsg + ": " + response.error
            end if
            allErrors.Push(errorMsg)
            LogError("PlaylistLoader", errorMsg)
        end if
    end for
    
    m.top.result = {
        channels: allChannels,
        groups: allGroups,
        errors: allErrors
    }
    
    if allErrors.Count() > 0 then
        m.top.status = "partial"
    else
        m.top.status = "complete"
    end if
    
    LogInfo("PlaylistLoader", "Loaded " + Str(allChannels.Count()) + " channels")
end sub
