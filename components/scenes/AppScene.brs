sub init()
    m.homeScene = m.top.FindNode("homeScene")
    m.top.ObserveField("launchArgs", "onLaunchArgsChanged")
    
    if m.top.launchArgs <> invalid and m.top.launchArgs.Count() > 0 then
        m.homeScene.launchArgs = m.top.launchArgs
    end if
    
    m.homeScene.setFocus(true)
end sub

sub onLaunchArgsChanged()
    if m.homeScene <> invalid then
        m.homeScene.launchArgs = m.top.launchArgs
    end if
end sub
