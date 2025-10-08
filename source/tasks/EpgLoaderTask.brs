sub EpgLoaderTaskRun()
    print "[INFO] [EpgLoader] EpgLoaderTaskRun() called"
    m.top.status = "loading"
    print "[INFO] [EpgLoader] Status set to loading"
    m.top.result = {
        channels: CreateObject("roAssociativeArray"),
        programs: CreateObject("roAssociativeArray"),
        nowNext: CreateObject("roAssociativeArray"),
        errors: []
    }
    print "[INFO] [EpgLoader] Result object initialized"
    
    xmltvUrl = m.top.xmltvUrl
    if xmltvUrl = invalid or xmltvUrl.Trim() = "" then
        m.top.result.errors.Push("No XMLTV URL provided")
        m.top.status = "error"
        print "[ERROR] [EpgLoader] No XMLTV URL provided"
        return
    end if
    
    print "[INFO] [EpgLoader] Fetching XMLTV: " + xmltvUrl
    
    response = FetchTextResource(xmltvUrl, {
        timeout: 30000,
        retries: 2,
        userAgent: "Dartts-IPTV/1.0"
    })
    
    if response.success then
        print "[INFO] [EpgLoader] Parsing XMLTV content (" + Str(Len(response.body)) + " bytes)"
        parsed = ParseXMLTV(response.body, { timeOffsetMinutes: 0 })
        
        m.top.result = parsed
        
        if parsed.errors.Count() > 0 then
            for each err in parsed.errors
                print "[WARN] [EpgLoader] XMLTV parse warning: " + err
            end for
            m.top.status = "partial"
        else
            m.top.status = "complete"
        end if
        
        print "[INFO] [EpgLoader] Loaded " + Str(parsed.channels.Count()) + " channels from EPG"
    else
        errorMsg = "Failed to fetch XMLTV"
        if response.error <> invalid then
            errorMsg = errorMsg + ": " + response.error
        end if
        m.top.result.errors.Push(errorMsg)
        print "[ERROR] [EpgLoader] " + errorMsg
        m.top.status = "error"
    end if
    
    print "[INFO] [EpgLoader] Task completed with status: " + m.top.status
end sub
