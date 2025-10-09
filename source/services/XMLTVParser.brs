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
            ' In Task context, use @attribute syntax instead of GetAttributes()
            channelId = channelNode@id
            if channelId = invalid or channelId = "" then
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
            ' In Task context, use @attribute syntax instead of GetAttributes()
            channelId = programmeNode@channel
            if channelId = invalid or channelId = "" then
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
    ' In Task context, use @attribute syntax
    channel.id = channelNode@id
    if channel.id = invalid then channel.id = ""
    channel.displayName = ""
    channel.icon = ""

    displayNodes = channelNode.GetNamedElements("display-name")
    if displayNodes <> invalid and displayNodes.Count() > 0 then
        textContent = displayNodes[0].GetText()
        if textContent <> invalid then
            channel.displayName = textContent.Trim()
        end if
    end if

    iconNodes = channelNode.GetNamedElements("icon")
    if iconNodes <> invalid and iconNodes.Count() > 0 then
        srcAttr = iconNodes[0]@src
        if srcAttr <> invalid then
            channel.icon = srcAttr
        end if
    end if

    return channel
end function

function ParseXmltvProgramme(programNode as object, timeOffset as integer) as dynamic
    ' In Task context, use @attribute syntax
    startText = programNode@start
    stopText = programNode@stop
    if startText = invalid then startText = ""
    if stopText = invalid then stopText = ""

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
            textContent = catNode.GetText()
            if textContent <> invalid then
                categories.Push(textContent.Trim())
            end if
        end for
        program.categories = categories
    end if

    program.startTime = startTime
    program.endTime = endTime

    episodeNodes = programNode.GetNamedElements("episode-num")
    if episodeNodes <> invalid and episodeNodes.Count() > 0 then
        for each epNode in episodeNodes
            ' In Task context, use @attribute syntax
            systemAttr = epNode@system
            if systemAttr = invalid then systemAttr = ""
            textContent = epNode.GetText()
            value = ""
            if textContent <> invalid then
                value = textContent.Trim()
            end if
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
        textContent = nodes[0].GetText()
        if textContent <> invalid then
            return textContent.Trim()
        end if
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

    ' Parse timestamp directly: YYYYMMDDHHMMSS +HHMM
    year = Val(Mid(cleaned, 1, 4))
    month = Val(Mid(cleaned, 5, 2))
    day = Val(Mid(cleaned, 7, 2))
    hour = Val(Mid(cleaned, 9, 2))
    minute = Val(Mid(cleaned, 11, 2))
    second = Val(Mid(cleaned, 13, 2))

    ' Convert to Unix timestamp (rough approximation for task context)
    ' Days since epoch (Jan 1, 1970)
    daysFromYears = (year - 1970) * 365
    leapYears = Int((year - 1969) / 4) - Int((year - 1901) / 100) + Int((year - 1601) / 400)
    daysFromYears = daysFromYears + leapYears
    
    ' Days in each month (non-leap year)
    monthDays = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
    daysFromMonths = monthDays[month - 1]
    if month > 2 and (year Mod 4 = 0 and (year Mod 100 <> 0 or year Mod 400 = 0)) then
        daysFromMonths = daysFromMonths + 1 ' Leap year adjustment
    end if
    
    totalDays = daysFromYears + daysFromMonths + day - 1
    totalSeconds = (totalDays * 86400) + (hour * 3600) + (minute * 60) + second

    ' Handle timezone offset if present
    if Len(cleaned) >= 19 then
        sign = Mid(cleaned, 15, 1)
        tzHour = Val(Mid(cleaned, 16, 2))
        tzMinute = Val(Mid(cleaned, 18, 2))
        tzOffsetSeconds = (tzHour * 3600) + (tzMinute * 60)
        if sign = "-" then tzOffsetSeconds = -tzOffsetSeconds
        ' Subtract timezone offset to get UTC
        totalSeconds = totalSeconds - tzOffsetSeconds
    end if

    if timeOffsetMinutes <> 0 then
        totalSeconds = totalSeconds + (timeOffsetMinutes * 60)
    end if

    ' Create roDateTime from seconds
    dt = CreateObject("roDateTime")
    dt.FromSeconds(totalSeconds)
    dt.ToLocalTime()
    return dt
end function
