' PlaylistLoaderTask - Background playlist loading task
' This task fetches and parses M3U playlists in a background thread

sub init()
    print "[INFO] [PlaylistLoader] Task initialized"
    m.top.functionName = "LoadPlaylists"
end sub

sub LoadPlaylists()
    print "[INFO] [PlaylistLoader] LoadPlaylists() called"
    
    m.top.status = "loading"
    m.top.result = {
        channels: [],
        groups: CreateObject("roAssociativeArray"),
        errors: []
    }
    
    urls = m.top.playlistUrls
    if urls = invalid or urls.Count() = 0 then
        print "[WARN] [PlaylistLoader] No playlist URLs provided"
        m.top.result.errors.Push("No playlist URLs provided")
        m.top.status = "error"
        return
    end if
    
    print "[INFO] [PlaylistLoader] Processing " + Str(urls.Count()) + " playlist(s)"
    
    allChannels = []
    allGroups = CreateObject("roAssociativeArray")
    allErrors = []
    
    for each url in urls
        print "[INFO] [PlaylistLoader] Fetching: " + url
        
        ' Fetch the playlist using roUrlTransfer
        transfer = CreateObject("roUrlTransfer")
        transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
        transfer.SetURL(url)
        
        content = transfer.GetToString()
        
        if content <> invalid and Len(content) > 0 then
            print "[INFO] [PlaylistLoader] Parsing M3U content (" + Str(Len(content)) + " bytes)"
            
            ' Parse the M3U content
            parsed = ParseM3UContent(content)
            
            ' Collect any parse errors
            if parsed.errors.Count() > 0 then
                for each err in parsed.errors
                    allErrors.Push("URL " + url + ": " + err)
                    print "[WARN] [PlaylistLoader] Parse error: " + err
                end for
            end if
            
            ' Merge channels
            for each channel in parsed.channels
                allChannels.Push(channel)
            end for
            
            ' Merge groups
            for each groupKey in parsed.groups
                if not allGroups.DoesExist(groupKey) then
                    allGroups[groupKey] = []
                end if
                for each ch in parsed.groups[groupKey]
                    allGroups[groupKey].Push(ch)
                end for
            end for
            
            print "[INFO] [PlaylistLoader] Loaded " + Str(parsed.channels.Count()) + " channels from this playlist"
        else
            ' Fetch failed
            errorMsg = "Failed to fetch " + url
            allErrors.Push(errorMsg)
            print "[ERROR] [PlaylistLoader] " + errorMsg
        end if
    end for
    
    ' Set final result
    m.top.result = {
        channels: allChannels,
        groups: allGroups,
        errors: allErrors
    }
    
    ' Set status based on results
    if allErrors.Count() > 0 and allChannels.Count() = 0 then
        m.top.status = "error"
    else if allErrors.Count() > 0 then
        m.top.status = "partial"
    else
        m.top.status = "complete"
    end if
    
    print "[INFO] [PlaylistLoader] Task completed - " + Str(allChannels.Count()) + " total channels, " + Str(allGroups.Count()) + " groups, " + Str(allErrors.Count()) + " errors"
end sub

' Simplified M3U parser for Task scope
function ParseM3UContent(content as string) as object
    result = {
        channels: [],
        groups: CreateObject("roAssociativeArray"),
        errors: []
    }

    if content = invalid or Len(content) = 0 then
        result.errors.Push("Empty playlist")
        return result
    end if

    ' Normalize line endings
    normalized = content.Replace(Chr(13) + Chr(10), Chr(10))
    normalized = normalized.Replace(Chr(13), Chr(10))
    
    ' Split into lines
    lines = []
    currentLine = ""
    for i = 0 to Len(normalized) - 1
        char = Mid(normalized, i + 1, 1)
        if char = Chr(10) then
            if Len(currentLine) > 0 then
                lines.Push(currentLine)
            end if
            currentLine = ""
        else
            currentLine = currentLine + char
        end if
    end for
    if Len(currentLine) > 0 then lines.Push(currentLine)

    if lines.Count() = 0 then
        result.errors.Push("Playlist could not be tokenized")
        return result
    end if

    ' Check for M3U header
    header = lines[0]
    if Instr(1, UCase(header), "#EXTM3U") = 0 then
        result.errors.Push("Missing #EXTM3U header")
    end if

    currentMeta = invalid
    channelIndex = 0

    for i = 1 to lines.Count() - 1
        line = lines[i]
        if Len(line) = 0 then goto continueLoop
        
        if Left(line, 1) = "#" then
            ' Metadata line
            if Instr(1, UCase(line), "#EXTINF") > 0 then
                ' Parse #EXTINF line
                currentMeta = ParseExtInfLine(line)
            end if
        else
            ' Stream URL
            if currentMeta = invalid then
                ' Create default metadata if missing
                currentMeta = {
                    title: "Channel " + Str(channelIndex + 1),
                    group: "Ungrouped",
                    logo: "",
                    tvgId: ""
                }
            end if

            ' Create channel object
            channel = {
                id: "ch_" + Str(channelIndex),
                title: currentMeta.title,
                streamUrl: line,
                group: currentMeta.group,
                logo: currentMeta.logo,
                tvgId: currentMeta.tvgId,
                index: channelIndex
            }

            result.channels.Push(channel)

            ' Add to group
            groupKey = channel.group
            if groupKey = invalid or groupKey = "" then groupKey = "Ungrouped"
            if not result.groups.DoesExist(groupKey) then
                result.groups[groupKey] = []
            end if
            result.groups[groupKey].Push(channel)

            channelIndex = channelIndex + 1
            currentMeta = invalid
        end if
        
        continueLoop:
    end for

    return result
end function

' Parse #EXTINF line to extract metadata
function ParseExtInfLine(line as string) as object
    meta = {
        title: "Unknown",
        group: "Ungrouped",
        logo: "",
        tvgId: ""
    }

    ' Find the colon that separates EXTINF: from the rest
    colonPos = Instr(1, line, ":")
    if colonPos = 0 then return meta

    ' Everything after the colon
    content = Mid(line, colonPos + 1)

    ' Extract group-title if present
    groupPos = Instr(1, content, "group-title=")
    if groupPos > 0 then
        groupStart = groupPos + 12
        ' Look for end quote
        if Mid(content, groupStart, 1) = Chr(34) then ' double quote
            groupStart = groupStart + 1
            groupEnd = Instr(groupStart, content, Chr(34))
            if groupEnd > 0 then
                meta.group = Mid(content, groupStart, groupEnd - groupStart)
            end if
        end if
    end if

    ' Extract tvg-logo if present
    logoPos = Instr(1, content, "tvg-logo=")
    if logoPos > 0 then
        logoStart = logoPos + 9
        if Mid(content, logoStart, 1) = Chr(34) then
            logoStart = logoStart + 1
            logoEnd = Instr(logoStart, content, Chr(34))
            if logoEnd > 0 then
                meta.logo = Mid(content, logoStart, logoEnd - logoStart)
            end if
        end if
    end if

    ' Extract tvg-id if present
    idPos = Instr(1, content, "tvg-id=")
    if idPos > 0 then
        idStart = idPos + 7
        if Mid(content, idStart, 1) = Chr(34) then
            idStart = idStart + 1
            idEnd = Instr(idStart, content, Chr(34))
            if idEnd > 0 then
                meta.tvgId = Mid(content, idStart, idEnd - idStart)
            end if
        end if
    end if

    ' Extract title (last comma-separated value)
    commaPos = Instr(1, content, ",")
    if commaPos > 0 then
        title = Mid(content, commaPos + 1)
        ' Trim whitespace
        while Left(title, 1) = " " and Len(title) > 0
            title = Mid(title, 2)
        end while
        if Len(title) > 0 then
            meta.title = title
        end if
    end if

    return meta
end function
