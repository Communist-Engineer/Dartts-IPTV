sub init()
    m.background = m.top.FindNode("background")
    m.channelLabel = m.top.FindNode("channelLabel")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.timeLabel = m.top.FindNode("timeLabel")
    
    m.top.focusable = true
end sub

sub OnContentChanged()
    content = m.top.itemContent
    if content <> invalid then
        if content.DoesExist("channelName") then
            m.channelLabel.text = content.channelName
        end if
        
        if content.DoesExist("title") then
            m.titleLabel.text = content.title
        end if
        
        if content.DoesExist("startTime") and content.DoesExist("endTime") then
            startTime = FormatTime(content.startTime)
            endTime = FormatTime(content.endTime)
            m.timeLabel.text = startTime + " - " + endTime
        end if
    end if
end sub

function FormatTime(dateTime as object) as string
    if dateTime = invalid then return ""
    hour = dateTime.GetHours()
    minute = dateTime.GetMinutes()
    ampm = "AM"
    
    if hour >= 12 then
        ampm = "PM"
        if hour > 12 then hour = hour - 12
    end if
    if hour = 0 then hour = 12
    
    minuteStr = Str(minute)
    if minute < 10 then minuteStr = "0" + minuteStr.Trim()
    
    return Str(hour).Trim() + ":" + minuteStr + " " + ampm
end function

sub onFocusChanged()
    if m.top.hasFocus() then
        m.background.color = "0x6D4C91FF"
    else
        m.background.color = "0x282828FF"
    end if
end sub
