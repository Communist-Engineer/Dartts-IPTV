function CacheDirectory() as string
    return "tmp:/dartts_iptv_cache"
end function

function LoadCache(key as string) as dynamic
    ensureCacheDir()
    path = CacheDirectory() + "/" + key + ".brsdata"
    data = ReadAsciiFile(path)
    if data = invalid then return invalid

    registry = CreateObject("roRegistrySection", "cache")
    if registry = invalid then return invalid

    return registry.Read(path)
end function

sub SaveCache(key as string, data as object)
    ensureCacheDir()
    path = CacheDirectory() + "/" + key + ".brsdata"

    registry = CreateObject("roRegistrySection", "cache")
    if registry = invalid then return

    registry.Write(path, data)
end sub

sub ClearCache()
    registry = CreateObject("roRegistrySection", "cache")
    if registry = invalid then return
    registry.DeleteAll()
end sub

sub ensureCacheDir()
    fs = CreateObject("roFileSystem")
    if fs = invalid then return
    dirPath = CacheDirectory()
    if not fs.Exists(dirPath) then
        fs.CreateDirectory(dirPath)
    end if
end sub
