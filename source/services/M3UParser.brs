function ParseM3U(content as string) as object
    result = {
        channels: [],
        groups: CreateObject("roAssociativeArray"),
        errors: []
    }

    if content = invalid or Len(content) = 0 then
        result.errors.Push("Empty playlist")
        return result
    end if

    lines = SplitContentLines(content)
    if lines.Count() = 0 then
        result.errors.Push("Playlist could not be tokenized")
        return result
    end if

    header = UCase(lines[0])
    if Instr(1, header, "#EXTM3U") = 0 then
        result.errors.Push("Missing #EXTM3U header")
    end if

    currentMeta = invalid
    groupOverride = invalid

    for each rawLine in lines
    line = rawLine.Trim()
        if line <> "" then
            if Left(line, 1) = "#" then
                upperLine = UCase(line)
                if Left(upperLine, 7) = "#EXTINF" then
                    currentMeta = ParseExtInf(line)
                else if Left(upperLine, 8) = "#EXTGRP" then
                    groupOverride = Mid(line, 8).Trim()
                else
                    if currentMeta <> invalid then
                        currentMeta.extraTags.Push(line)
                    end if
                end if
            else
                if currentMeta = invalid then
                    result.errors.Push("Stream URL without preceding #EXTINF: " + line)
                    currentMeta = CreateDefaultMetadata()
                end if

                streamUrl = NormalizeStreamUrl(line)
                channel = BuildChannel(currentMeta, streamUrl, groupOverride)
                result.channels.Push(channel)

                groupKey = channel.group
                if groupKey = invalid or groupKey = "" then groupKey = "Ungrouped"

                if not result.groups.DoesExist(groupKey) then result.groups[groupKey] = []
                result.groups[groupKey].Push(channel)

                currentMeta = invalid
                groupOverride = invalid
            end if
        end if
    end for

    return result
end function

function SplitContentLines(content as string) as object
    normalized = content.Replace(Chr(13) + Chr(10), Chr(10))
    normalized = normalized.Replace(Chr(13), Chr(10))
    regex = CreateObject("roRegex", "\n+", "")
    return regex.Split(normalized)
end function

function ParseExtInf(line as string) as object
    meta = CreateDefaultMetadata()
    meta.raw = line

    colonIndex = Instr(1, line, ":")
    if colonIndex = 0 then return meta

    header = Mid(line, colonIndex + 1)

    semicolonIndex = Instr(1, header, ";")
    attributesPart = header
    if semicolonIndex > 0 then
        attributesPart = Left(header, semicolonIndex - 1)
        meta.name = Mid(header, semicolonIndex + 1).Trim()
    else
        meta.name = header.Trim()
    end if

    durationText = Mid(line, 9)
    spaceIndex = Instr(1, durationText, " ")
    if spaceIndex > 0 then
        durationText = Left(durationText, spaceIndex - 1)
    end if
    duration = Val(durationText)
    if duration >= 0 then meta.duration = duration

    regex = CreateObject("roRegex", "([A-Za-z0-9\-]+?)=""([^""]*)""", "i")
    if regex <> invalid then
        matches = regex.MatchAll(attributesPart)
        for each match in matches
            if match.Count() >= 3 then
                key = LCase(match[1])
                value = match[2].Trim()
                meta.attributes[key] = value
            end if
        end for
    end if

    if meta.name = "" and meta.attributes.DoesExist("tvg-name") then
        meta.name = meta.attributes["tvg-name"]
    end if

    if meta.attributes.DoesExist("tvg-logo") then meta.logo = meta.attributes["tvg-logo"]
    if meta.attributes.DoesExist("group-title") then meta.group = meta.attributes["group-title"]
    if meta.attributes.DoesExist("tvg-id") then meta.tvgId = meta.attributes["tvg-id"]

    return meta
end function

function CreateDefaultMetadata() as object
    meta = CreateObject("roAssociativeArray")
    meta.name = ""
    meta.duration = -1
    meta.logo = ""
    meta.group = ""
    meta.tvgId = ""
    meta.attributes = CreateObject("roAssociativeArray")
    meta.extraTags = []
    meta.raw = ""
    return meta
end function

function NormalizeStreamUrl(url as string) as string
    trimmed = url.Trim()
    if trimmed = "" then return trimmed
    return trimmed
end function

function BuildChannel(meta as object, streamUrl as string, groupOverride as dynamic) as object
    channel = CreateObject("roAssociativeArray")
    channel.id = GenerateChannelId(meta, streamUrl)
    channel.name = meta.name
    channel.streamUrl = streamUrl
    channel.duration = meta.duration
    channel.logo = meta.logo
    channel.group = groupOverride
    if channel.group = invalid or channel.group = "" then channel.group = meta.group
    channel.tvgId = meta.tvgId
    channel.attributes = meta.attributes
    channel.extraTags = meta.extraTags
    channel.raw = meta.raw
    channel.isHttp = Left(LCase(streamUrl), 4) = "http"
    return channel
end function

function GenerateChannelId(meta as object, streamUrl as string) as string
    digestSource = streamUrl + "|" + meta.name + "|" + meta.tvgId
    return ShortHash(digestSource)
end function

function ShortHash(value as string) as string
    digest = CreateObject("roEVPDigest")
    digest.Setup("md5")
    digest.Update(value)
    return digest.Final().Mid(0, 16)
end function
