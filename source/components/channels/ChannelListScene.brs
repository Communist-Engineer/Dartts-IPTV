sub ChannelListSceneInit()
    m.titleLabel = m.top.FindNode("titleLabel")
    m.placeholderLabel = m.top.FindNode("placeholderLabel")
    m.top.ObserveField("title", "ChannelListSceneOnTitleChanged")
end sub

sub ChannelListSceneOnTitleChanged()
    if m.titleLabel <> invalid then
        m.titleLabel.text = m.top.title
    end if
end sub
