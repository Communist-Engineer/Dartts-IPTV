sub init()
    print "[INFO] [CATEGORYITEM] CategoryListItem init() called"
    m.background = m.top.FindNode("background")
    m.categoryLabel = m.top.FindNode("categoryLabel")
    m.countLabel = m.top.FindNode("countLabel")
    
    bgStr = "invalid"
    if m.background <> invalid then bgStr = "valid"
    print "[INFO] [CATEGORYITEM] background: " + bgStr
    
    catStr = "invalid"
    if m.categoryLabel <> invalid then catStr = "valid"
    print "[INFO] [CATEGORYITEM] categoryLabel: " + catStr
    
    cntStr = "invalid"
    if m.countLabel <> invalid then cntStr = "valid"
    print "[INFO] [CATEGORYITEM] countLabel: " + cntStr
    
    m.top.focusable = true
    print "[INFO] [CATEGORYITEM] CategoryListItem initialized"
end sub

sub OnContentChanged()
    print "[INFO] [CATEGORYITEM] OnContentChanged() called"
    content = m.top.itemContent
    
    if content = invalid then
        print "[INFO] [CATEGORYITEM] content is invalid"
        return
    end if
    
    print "[INFO] [CATEGORYITEM] content is valid"
    
    if content.category <> invalid then
        print "[INFO] [CATEGORYITEM] content.category: " + content.category
    else
        print "[INFO] [CATEGORYITEM] content.category is invalid"
    end if
    
    if content.count <> invalid then
        print "[INFO] [CATEGORYITEM] content.count: " + Str(content.count)
    else
        print "[INFO] [CATEGORYITEM] content.count is invalid"
    end if
    
    ' content is a ContentNode, access fields directly
    if content.category <> invalid then
        m.categoryLabel.text = content.category
        print "[INFO] [CATEGORYITEM] Set categoryLabel.text to: " + content.category
    end if
    
    if content.count <> invalid then
        m.countLabel.text = Str(content.count) + " live now"
        print "[INFO] [CATEGORYITEM] Set countLabel.text to: " + Str(content.count) + " live now"
    end if
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.background.color = "0x6D4C91FF"
    else
        m.background.color = "0x303030FF"
    end if
end sub
