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

    scene = screen.CreateScene("MainScene")
    ' Note: CreateScene automatically sets the scene, but we keep the reference for potential future use
    if scene = invalid then
        print "ERROR: Failed to create MainScene"
        return
    end if
    
    screen.Show()

    while true
        msg = Wait(0, port)
        if type(msg) = "roSGScreenEvent" then
            if msg.IsScreenClosed() then exit while
        end if
    end while
end sub

function GetDeepLinkArgs() as object
    ' Deep linking arguments will be passed to the scene via roAppManager
    ' For now, return empty object - we'll handle deep links via the scene's launch event
    return {}
end function

sub InitializeAppConfig()
    ' TODO: Load persisted settings, set defaults, version caches.
end sub
