function CreateChannel(data as object) as object
    channel = {
        id: data.Lookup("id", invalid),
        name: data.Lookup("name", ""),
        group: data.Lookup("group", ""),
        logo: data.Lookup("logo", ""),
        streamUrl: data.Lookup("streamUrl", ""),
        duration: data.Lookup("duration", 0),
        extras: data
    }
    return channel
end function
