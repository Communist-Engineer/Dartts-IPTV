sub EpgLoaderTaskRun()
    m.top.status = "loading"
    m.top.result = {
        channels: CreateObject("roAssociativeArray"),
        programs: CreateObject("roAssociativeArray"),
        nowNext: CreateObject("roAssociativeArray"),
        errors: []
    }
    
    xmltvUrl = m.top.xmltvUrl
    if xmltvUrl = invalid or xmltvUrl.Trim() = "" then
        m.top.result.errors.Push("No XMLTV URL provided")
        m.top.status = "error"
        return
    end if
    
    LogInfo("EpgLoader", "Fetching XMLTV: " + xmltvUrl)
    
    response = FetchTextResource(xmltvUrl, {
        timeout: 30000,
        retries: 2,
        userAgent: "Dartts-IPTV/1.0"
    })
    
    if response.success then
        LogInfo("EpgLoader", "Parsing XMLTV content")
        parsed = ParseXMLTV(response.body, { timeOffsetMinutes: 0 })
        
        m.top.result = parsed
        
        if parsed.errors.Count() > 0 then
            for each err in parsed.errors
                LogWarn("EpgLoader", "XMLTV parse warning: " + err)
            end for
            m.top.status = "partial"
        else
            m.top.status = "complete"
        end if
        
        LogInfo("EpgLoader", "Loaded " + Str(parsed.channels.Count()) + " channels from EPG")
    else
        errorMsg = "Failed to fetch XMLTV"
        if response.error <> invalid then
            errorMsg = errorMsg + ": " + response.error
        end if
        m.top.result.errors.Push(errorMsg)
        LogError("EpgLoader", errorMsg)
        m.top.status = "error"
    end if
end sub
