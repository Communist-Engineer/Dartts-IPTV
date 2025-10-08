sub SettingsModalInit()
    m.body = m.top.FindNode("body")
    m.top.ObserveField("settings", "SettingsModalOnSettingsChanged")
end sub

sub SettingsModalOnSettingsChanged()
    if m.body = invalid then return
    m.body.text = "Configure playlists, XMLTV, and preferences in upcoming implementation."
end sub
