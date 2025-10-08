sub GuideViewInit()
    m.statusLabel = m.top.FindNode("status")
    m.top.ObserveField("epgData", "GuideViewOnEpgDataChanged")
end sub

sub GuideViewOnEpgDataChanged()
    if m.statusLabel = invalid then return

    if m.top.epgData = invalid or m.top.epgData.count() = 0 then
        m.statusLabel.text = "No guide data loaded"
    else
        m.statusLabel.text = "Guide ready"
    end if
end sub
