sub init()
    m.background = m.top.FindNode("background")
    m.categoryLabel = m.top.FindNode("categoryLabel")
    m.countLabel = m.top.FindNode("countLabel")
    
    m.top.focusable = true
    m.top.focusBitmapUri = ""
    m.top.focusFootprintBitmapUri = ""
end sub

sub OnContentChanged()
    content = m.top.itemContent
    if content <> invalid then
        if content.DoesExist("category") then
            m.categoryLabel.text = content.category
        end if
        
        if content.DoesExist("count") then
            m.countLabel.text = Str(content.count) + " live now"
        end if
    end if
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.background.color = "0x6D4C91FF"
    else
        m.background.color = "0x303030FF"
    end if
end sub
