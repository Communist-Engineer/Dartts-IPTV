sub NoticeDialogInit()
    m.top.title = "Legal Notice"
    m.top.buttons = ["OK"]
    if m.top.message = invalid or m.top.message = "" then
        m.top.message = "Dartt's IPTV plays user-provided streams. Ensure you have rights to all content you load."
    end if
end sub
