sub init()
    m.testLabel = m.top.FindNode("testLabel")
    m.statusLabel = m.top.FindNode("statusLabel")
    
    ' Set up basic UI
    if m.testLabel <> invalid
        m.testLabel.font.size = 48
    end if
    
    if m.statusLabel <> invalid
        m.statusLabel.font.size = 32
    end if
end sub
