sub Main()
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)

    m.global = screen.GetGlobalNode()
    m.global.AddField("appConfig", "assocarray")
    m.global.AddField("cache", "assocarray")
    m.global.AddField("deepLinkArgs", "assocarray")

    ' placeholder for initializing persistent storage/config
    InitializeAppConfig()

    scene = screen.CreateScene("AppScene")
    scene.AddField("launchArgs", "assocarray")
    scene.launchArgs = GetDeepLinkArgs()

    screen.SetRoot(scene)
    screen.Show()

    while true
        msg = Wait(0, port)
        if type(msg) = "roSGScreenEvent" then
            if msg.IsScreenClosed() then exit while
        end if
    end while
end sub

function GetDeepLinkArgs() as object
    launchParams = CreateObject("roInput")
    if launchParams <> invalid then
        inputData = launchParams.GetMessage()
        if type(inputData) = "roAssociativeArray" then
            return inputData
        end if
    end if
    return {}
end function

sub InitializeAppConfig()
    ' TODO: Load persisted settings, set defaults, version caches.
end sub
