sub Main()
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)

    m.global = screen.GetGlobalNode()
    ' Add fields to global node using addFields (plural) with field definitions
    m.global.addFields({
        appConfig: {},
        cache: {},
        deepLinkArgs: {}
    })

    ' placeholder for initializing persistent storage/config
    InitializeAppConfig()

    scene = screen.CreateScene("AppScene")
    ' Set launch args on the scene (field is defined in AppScene.xml)
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
