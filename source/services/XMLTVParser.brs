function ParseXMLTV(xmlContent as string, options = invalid) as object
    result = {
        channels: CreateObject("roAssociativeArray"),
        programs: CreateObject("roAssociativeArray"),
        nowNext: CreateObject("roAssociativeArray"),
        errors: []
    }

    if xmlContent = invalid or Len(xmlContent) = 0 then
        result.errors.Push("Empty XMLTV data")
        return result
    end if

    timeOffset = 0
    if options <> invalid and options.DoesExist("timeOffsetMinutes") then
        timeOffset = options.timeOffsetMinutes
    end if

    xml = CreateObject("roXMLElement")
    if not xml.Parse(xmlContent) then
        result.errors.Push("XMLTV parse error")
        return result
    end if

    channelNodes = xml.GetNamedElements("channel")
    if channelNodes <> invalid then
        for each channelNode in channelNodes
            channelId = channelNode.GetAttributes().Lookup("id", "")
            if channelId = "" then
                result.errors.Push("Channel element missing id")
            else
                channelInfo = ParseXmltvChannel(channelNode)
                result.channels[channelId] = channelInfo
            end if
        end for
    end if

    programmeNodes = xml.GetNamedElements("programme")
    if programmeNodes <> invalid then
        for each programmeNode in programmeNodes
            channelId = programmeNode.GetAttributes().Lookup("channel", "")
            if channelId = "" then
                result.errors.Push("Programme missing channel attribute")
            else
                programInfo = ParseXmltvProgramme(programmeNode, timeOffset)
                if programInfo <> invalid then
                    EnsureProgramArray(result.programs, channelId)
                    result.programs[channelId].Push(programInfo)
                end if
            end if
        end for
    end if

    SortPrograms(result.programs)
    BuildNowNext(result.programs, result.nowNext)

    return result
end function

function ParseXmltvChannel(channelNode as object) as object
    channel = CreateObject("roAssociativeArray")
    channel.id = channelNode.GetAttributes().Lookup("id", "")
    channel.displayName = ""
    channel.icon = ""

    displayNodes = channelNode.GetNamedElements("display-name")
    if displayNodes <> invalid and displayNodes.Count() > 0 then
        channel.displayName = displayNodes[0].GetText().Trim()
    end if

    iconNodes = channelNode.GetNamedElements("icon")
    if iconNodes <> invalid and iconNodes.Count() > 0 then
        channel.icon = iconNodes[0].GetAttributes().Lookup("src", "")
    end if

    return channel
end function

function ParseXmltvProgramme(programNode as object, timeOffset as integer) as dynamic
    attrs = programNode.GetAttributes()
    startText = attrs.Lookup("start", "")
    stopText = attrs.Lookup("stop", "")

    startTime = ParseXmltvTime(startText, timeOffset)
    endTime = ParseXmltvTime(stopText, timeOffset)
    if startTime = invalid then return invalid

    program = CreateObject("roAssociativeArray")
    program.title = ExtractFirstText(programNode, "title")
    program.subTitle = ExtractFirstText(programNode, "sub-title")
    program.description = ExtractFirstText(programNode, "desc")

    creditsNode = programNode.GetNamedElements("credits")
    if creditsNode <> invalid and creditsNode.Count() > 0 then
        program.credits = creditsNode
    end if

    categoryNodes = programNode.GetNamedElements("category")
    if categoryNodes <> invalid and categoryNodes.Count() > 0 then
        categories = []
        for each catNode in categoryNodes
            categories.Push(catNode.GetText().Trim())
        end for
        program.categories = categories
    end if

    program.startTime = startTime
    program.endTime = endTime

    episodeNodes = programNode.GetNamedElements("episode-num")
    if episodeNodes <> invalid and episodeNodes.Count() > 0 then
        for each epNode in episodeNodes
            systemAttr = epNode.GetAttributes().Lookup("system", "")
            value = epNode.GetText().Trim()
            if systemAttr = "xmltv_ns" then
                parts = value.Split(".")
                if parts.Count() >= 2 then
                    program.season = Val(parts[0]) + 1
                    program.episode = Val(parts[1]) + 1
                end if
            else if systemAttr = "onscreen" and program.description = "" then
                program.description = value
            end if
        end for
    end if

    return program
end function

function ExtractFirstText(parentNode as object, elementName as string) as string
    nodes = parentNode.GetNamedElements(elementName)
    if nodes <> invalid and nodes.Count() > 0 then
        return nodes[0].GetText().Trim()
    end if
    return ""
end function

function EnsureProgramArray(programMap as object, channelId as string)
    if not programMap.DoesExist(channelId) then
        programMap[channelId] = []
    end if
end function

sub SortPrograms(programMap as object)
    for each channelId in programMap
        programs = programMap[channelId]
        if programs.Count() > 1 then
            quickSortPrograms(programs, 0, programs.Count() - 1)
        end if
    end for
end sub

sub quickSortPrograms(programs as object, low as integer, high as integer)
    if low >= high then return
    pivotIndex = Int((low + high) / 2)
    pivot = programs[pivotIndex]
    i = low
    j = high

    while i <= j
        while CompareProgram(programs[i], pivot) < 0
            i = i + 1
        end while
        while CompareProgram(programs[j], pivot) > 0
            j = j - 1
        end while
        if i <= j then
            tmp = programs[i]
            programs[i] = programs[j]
            programs[j] = tmp
            i = i + 1
            j = j - 1
        end if
    end while

    if low < j then quickSortPrograms(programs, low, j)
    if i < high then quickSortPrograms(programs, i, high)
end sub

function CompareProgram(a as object, b as object) as integer
    if a.startTime.AsSeconds() < b.startTime.AsSeconds() then return -1
    if a.startTime.AsSeconds() > b.startTime.AsSeconds() then return 1
    return 0
end function

sub BuildNowNext(programMap as object, nowNextMap as object)
    now = CreateObject("roDateTime")
    now.ToLocalTime()
    currentSeconds = now.AsSeconds()

    for each channelId in programMap
        programs = programMap[channelId]
        nowEntry = {
            now: invalid,
            next: invalid
        }

        for each program in programs
            startSeconds = program.startTime.AsSeconds()
            endSeconds = startSeconds
            if program.endTime <> invalid then
                endSeconds = program.endTime.AsSeconds()
            end if

            if currentSeconds >= startSeconds and currentSeconds < endSeconds then
                nowEntry.now = program
            else if startSeconds > currentSeconds then
                nowEntry.next = program
                exit for
            end if
        end for

        nowNextMap[channelId] = nowEntry
    end for
end sub

function ParseXmltvTime(timestamp as string, timeOffsetMinutes as integer) as dynamic
    if timestamp = invalid or Len(timestamp) < 14 then return invalid
    cleaned = timestamp.Replace(" ", "")

    iso = Left(cleaned, 4) + "-" + Mid(cleaned, 5, 2) + "-" + Mid(cleaned, 7, 2) + "T" + Mid(cleaned, 9, 2) + ":" + Mid(cleaned, 11, 2) + ":" + Mid(cleaned, 13, 2)

    if Len(cleaned) >= 19 then
        sign = Mid(cleaned, 15, 1)
        offset = Mid(cleaned, 16, 2) + ":" + Mid(cleaned, 18, 2)
        iso = iso + sign + offset
    else
        iso = iso + "Z"
    end if

    dt = CreateObject("roDateTime")
    if not dt.FromISO8601String(iso) then return invalid

    if timeOffsetMinutes <> 0 then
        dt.AddSeconds(timeOffsetMinutes * 60)
    end if

    dt.ToLocalTime()
    return dt
end function
