sub LogDebug(tag as string, message as string)
    DarttsLog(tag, "DEBUG", message)
end sub

sub LogInfo(tag as string, message as string)
    DarttsLog(tag, "INFO", message)
end sub

sub LogWarn(tag as string, message as string)
    DarttsLog(tag, "WARN", message)
end sub

sub LogError(tag as string, message as string)
    DarttsLog(tag, "ERROR", message)
end sub

sub DarttsLog(tag as string, level as string, message as string)
    timestamp = CreateObject("roDateTime")
    timestamp.ToLocalTime()
    print "[" + level + "] [" + tag + "] [" + timestamp.ToISOString() + "] " + message
end sub
