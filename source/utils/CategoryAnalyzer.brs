' ============================
' Category Analyzer
' Analyzes EPG programs and groups them by detected categories
' ============================

function AnalyzeAndGroupPrograms(epgData as object, channels as object) as object
    result = {
        categories: CreateObject("roAssociativeArray"),
        sports: CreateObject("roAssociativeArray"),
        movies: CreateObject("roAssociativeArray"),
        tvShows: CreateObject("roAssociativeArray")
    }
    
    if epgData = invalid or epgData.nowNext = invalid then
        return result
    end if
    
    ' Get current time
    now = CreateObject("roDateTime")
    now.ToLocalTime()
    
    ' Process each channel's current program
    for each channelId in epgData.nowNext
        nowNext = epgData.nowNext[channelId]
        if nowNext <> invalid and nowNext.now <> invalid then
            program = nowNext.now
            
            ' Find matching channel info
            channelInfo = FindChannelById(channels, channelId)
            if channelInfo <> invalid then
                ' Add channel reference to program
                program.channel = channelInfo
                program.channelName = channelInfo.title
                
                ' Detect and categorize
                DetectAndAddToCategory(program, result)
            end if
        end if
    end for
    
    return result
end function

function FindChannelById(channels as object, epgChannelId as string) as dynamic
    ' Try to match EPG channel ID with M3U channel
    ' Common patterns: channel ID might match tvg-id or be derived from name
    
    for each channel in channels
        ' Check tvg-id first
        if channel.DoesExist("tvgId") and channel.tvgId = epgChannelId then
            return channel
        end if
        
        ' Check if channel name contains the EPG channel ID
        if channel.DoesExist("title") then
            cleanTitle = LCase(channel.title).Replace(" ", "").Replace("-", "")
            cleanEpgId = LCase(epgChannelId).Replace(" ", "").Replace("-", "")
            if cleanTitle = cleanEpgId or cleanTitle.Instr(cleanEpgId) >= 0 then
                return channel
            end if
        end if
    end for
    
    return invalid
end function

sub DetectAndAddToCategory(program as object, result as object)
    ' Detect sports leagues
    sportsLeague = DetectSportsLeague(program)
    if sportsLeague <> "" then
        AddToCategory(result.sports, sportsLeague, program)
        AddToCategory(result.categories, "Sports: " + sportsLeague, program)
        return
    end if
    
    ' Detect movie genres
    if IsMovie(program) then
        genre = DetectMovieGenre(program)
        AddToCategory(result.movies, genre, program)
        AddToCategory(result.categories, "Movies: " + genre, program)
        return
    end if
    
    ' Detect TV show genres
    tvGenre = DetectTVGenre(program)
    if tvGenre <> "" then
        AddToCategory(result.tvShows, tvGenre, program)
        AddToCategory(result.categories, "TV: " + tvGenre, program)
        return
    end if
    
    ' Default: Other
    AddToCategory(result.categories, "Other", program)
end sub

function DetectSportsLeague(program as object) as string
    title = ""
    description = ""
    categories = []
    
    if program.DoesExist("title") then title = LCase(program.title)
    if program.DoesExist("description") then description = LCase(program.description)
    if program.DoesExist("categories") then categories = program.categories
    
    searchText = title + " " + description
    
    ' NFL
    if searchText.Instr("nfl") >= 0 or searchText.Instr("football") >= 0 then
        if searchText.Instr("american") >= 0 or searchText.Instr("nfl") >= 0 then
            return "NFL"
        end if
    end if
    
    ' MLB
    if searchText.Instr("mlb") >= 0 or searchText.Instr("baseball") >= 0 then
        return "MLB"
    end if
    
    ' NBA
    if searchText.Instr("nba") >= 0 or searchText.Instr("basketball") >= 0 then
        return "NBA"
    end if
    
    ' NHL
    if searchText.Instr("nhl") >= 0 or searchText.Instr("hockey") >= 0 then
        return "NHL"
    end if
    
    ' Formula 1
    if searchText.Instr("formula") >= 0 or searchText.Instr("f1") >= 0 or searchText.Instr(" f 1") >= 0 then
        return "Formula 1"
    end if
    
    ' NASCAR
    if searchText.Instr("nascar") >= 0 then
        return "NASCAR"
    end if
    
    ' Soccer/Football leagues
    if searchText.Instr("premier league") >= 0 or searchText.Instr("epl") >= 0 then
        return "Premier League"
    end if
    
    if searchText.Instr("la liga") >= 0 or searchText.Instr("laliga") >= 0 then
        return "La Liga"
    end if
    
    if searchText.Instr("bundesliga") >= 0 then
        return "Bundesliga"
    end if
    
    if searchText.Instr("serie a") >= 0 then
        return "Serie A"
    end if
    
    if searchText.Instr("mls") >= 0 or searchText.Instr("major league soccer") >= 0 then
        return "MLS"
    end if
    
    if searchText.Instr("champions league") >= 0 or searchText.Instr("ucl") >= 0 then
        return "Champions League"
    end if
    
    if searchText.Instr("soccer") >= 0 or searchText.Instr("fifa") >= 0 then
        return "Soccer"
    end if
    
    ' UFC/MMA
    if searchText.Instr("ufc") >= 0 or searchText.Instr("mma") >= 0 then
        return "UFC/MMA"
    end if
    
    ' Boxing
    if searchText.Instr("boxing") >= 0 or searchText.Instr("fight") >= 0 then
        return "Boxing"
    end if
    
    ' Tennis
    if searchText.Instr("tennis") >= 0 or searchText.Instr("wimbledon") >= 0 or searchText.Instr("us open") >= 0 then
        return "Tennis"
    end if
    
    ' Golf
    if searchText.Instr("golf") >= 0 or searchText.Instr("pga") >= 0 then
        return "Golf"
    end if
    
    ' Check categories
    for each cat in categories
        catLower = LCase(cat)
        if catLower = "sports" or catLower = "sport" then
            return "General Sports"
        end if
    end for
    
    return ""
end function

function IsMovie(program as object) as boolean
    if program.DoesExist("categories") then
        for each cat in program.categories
            catLower = LCase(cat)
            if catLower = "movie" or catLower = "film" or catLower = "movies" then
                return true
            end if
        end for
    end if
    
    ' Check if it has no episode info (likely a movie)
    if program.DoesExist("season") = false and program.DoesExist("episode") = false then
        ' Check duration (movies typically 90+ minutes)
        if program.DoesExist("startTime") and program.DoesExist("endTime") then
            duration = program.endTime.AsSeconds() - program.startTime.AsSeconds()
            if duration >= 5400 then ' 90 minutes
                return true
            end if
        end if
    end if
    
    return false
end function

function DetectMovieGenre(program as object) as string
    title = ""
    description = ""
    categories = []
    
    if program.DoesExist("title") then title = LCase(program.title)
    if program.DoesExist("description") then description = LCase(program.description)
    if program.DoesExist("categories") then categories = program.categories
    
    searchText = title + " " + description
    
    ' Check categories first
    for each cat in categories
        catLower = LCase(cat)
        if catLower <> "movie" and catLower <> "film" and catLower <> "movies" then
            ' Return the first non-movie category as genre
            return cat
        end if
    end for
    
    ' Detect from title/description
    if searchText.Instr("action") >= 0 or searchText.Instr("adventure") >= 0 then
        return "Action"
    else if searchText.Instr("comedy") >= 0 or searchText.Instr("funny") >= 0 then
        return "Comedy"
    else if searchText.Instr("drama") >= 0 then
        return "Drama"
    else if searchText.Instr("horror") >= 0 or searchText.Instr("scary") >= 0 then
        return "Horror"
    else if searchText.Instr("thriller") >= 0 or searchText.Instr("suspense") >= 0 then
        return "Thriller"
    else if searchText.Instr("romance") >= 0 or searchText.Instr("romantic") >= 0 then
        return "Romance"
    else if searchText.Instr("sci-fi") >= 0 or searchText.Instr("science fiction") >= 0 then
        return "Sci-Fi"
    else if searchText.Instr("fantasy") >= 0 then
        return "Fantasy"
    else if searchText.Instr("documentary") >= 0 then
        return "Documentary"
    else if searchText.Instr("animation") >= 0 or searchText.Instr("animated") >= 0 then
        return "Animation"
    else if searchText.Instr("family") >= 0 or searchText.Instr("kids") >= 0 then
        return "Family"
    else if searchText.Instr("western") >= 0 then
        return "Western"
    else if searchText.Instr("crime") >= 0 or searchText.Instr("mystery") >= 0 then
        return "Crime"
    end if
    
    return "General"
end function

function DetectTVGenre(program as object) as string
    title = ""
    description = ""
    categories = []
    
    if program.DoesExist("title") then title = LCase(program.title)
    if program.DoesExist("description") then description = LCase(program.description)
    if program.DoesExist("categories") then categories = program.categories
    
    searchText = title + " " + description
    
    ' Check categories
    for each cat in categories
        catLower = LCase(cat)
        if catLower.Instr("series") >= 0 or catLower.Instr("drama") >= 0 then
            return cat
        end if
        if catLower.Instr("comedy") >= 0 then
            return "Comedy"
        end if
        if catLower.Instr("news") >= 0 then
            return "News"
        end if
        if catLower.Instr("documentary") >= 0 or catLower.Instr("docuseries") >= 0 then
            return "Documentary"
        end if
    end for
    
    ' Detect from content
    if searchText.Instr("news") >= 0 or searchText.Instr("breaking") >= 0 then
        return "News"
    else if searchText.Instr("reality") >= 0 or searchText.Instr("competition") >= 0 then
        return "Reality"
    else if searchText.Instr("talk show") >= 0 or searchText.Instr("interview") >= 0 then
        return "Talk Show"
    else if searchText.Instr("sitcom") >= 0 or searchText.Instr("comedy") >= 0 then
        return "Comedy"
    else if searchText.Instr("drama") >= 0 then
        return "Drama"
    else if searchText.Instr("documentary") >= 0 then
        return "Documentary"
    else if searchText.Instr("cartoon") >= 0 or searchText.Instr("animation") >= 0 then
        return "Animation"
    else if searchText.Instr("game show") >= 0 then
        return "Game Show"
    else if searchText.Instr("cooking") >= 0 or searchText.Instr("chef") >= 0 then
        return "Cooking"
    end if
    
    return "General"
end function

sub AddToCategory(categoryMap as object, categoryName as string, program as object)
    if not categoryMap.DoesExist(categoryName) then
        categoryMap[categoryName] = []
    end if
    categoryMap[categoryName].Push(program)
end sub
