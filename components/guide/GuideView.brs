sub init()
    LogInfo("GUIDE", "Initializing Guide View")
    
    m.background = m.top.FindNode("background")
    m.header = m.top.FindNode("header")
    m.subtitle = m.top.FindNode("subtitle")
    m.categoryList = m.top.FindNode("categoryList")
    m.programBackground = m.top.FindNode("programBackground")
    m.programHeader = m.top.FindNode("programHeader")
    m.programList = m.top.FindNode("programList")
    m.helpLabel = m.top.FindNode("helpLabel")
    
    m.categoryList.ObserveField("itemSelected", "OnCategorySelected")
    m.programList.ObserveField("itemSelected", "OnProgramSelected")
    
    m.top.ObserveField("categorizedPrograms", "OnCategorizedProgramsChanged")
    
    m.categories = []
    m.currentCategoryIndex = -1
    m.showingPrograms = false
    
    LogInfo("GUIDE", "Guide View initialized")
end sub

sub LogInfo(tag as string, message as string)
    print "[INFO] [" + tag + "] " + message
end sub

sub LogDebug(tag as string, message as string)
    print "[DEBUG] [" + tag + "] " + message
end sub

sub OnCategorizedProgramsChanged()
    data = m.top.categorizedPrograms
    if data = invalid or data.categories = invalid then
        LogInfo("GUIDE", "No categorized programs data")
        return
    end if
    
    LogInfo("GUIDE", "Categorized programs received")
    
    ' Build category list
    m.categories = []
    for each categoryName in data.categories
        programs = data.categories[categoryName]
        m.categories.Push({
            category: categoryName,
            count: programs.Count(),
            programs: programs
        })
    end for
    
    LogInfo("GUIDE", "Built " + Str(m.categories.Count()) + " categories")
    
    ' Populate category list
    content = CreateObject("roSGNode", "ContentNode")
    row = content.CreateChild("ContentNode")
    
    for each cat in m.categories
        item = row.CreateChild("ContentNode")
        item.category = cat.category
        item.count = cat.count
    end for
    
    m.categoryList.content = content
    m.categoryList.setFocus(true)
    
    LogInfo("GUIDE", "Category list populated")
end sub

sub OnCategorySelected()
    index = m.categoryList.itemSelected
    if index < 0 or index >= m.categories.Count() then return
    
    m.currentCategoryIndex = index
    category = m.categories[index]
    
    LogInfo("GUIDE", "Category selected: " + category.category)
    
    ' Show program list
    ShowProgramList(category)
end sub

sub ShowProgramList(category as object)
    m.showingPrograms = true
    
    ' Update header
    m.programHeader.text = category.category + " - Live Now"
    
    ' Build program content
    content = CreateObject("roSGNode", "ContentNode")
    for each program in category.programs
        item = content.CreateChild("ContentNode")
        item.channelName = program.channelName
        item.title = program.title
        item.description = program.description
        item.startTime = program.startTime
        item.endTime = program.endTime
        item.channel = program.channel
    end for
    
    m.programList.content = content
    
    ' Show program UI
    m.programBackground.visible = true
    m.programHeader.visible = true
    m.programList.visible = true
    
    ' Give focus to program list
    m.programList.setFocus(true)
    m.programList.jumpToItem = 0
    
    ' Update help text
    m.helpLabel.text = "◀ Back to categories  •  OK to play channel"
    
    LogInfo("GUIDE", "Showing " + Str(category.programs.Count()) + " programs")
end sub

sub OnProgramSelected()
    if not m.showingPrograms then return
    
    index = m.programList.itemSelected
    if m.currentCategoryIndex < 0 then return
    
    category = m.categories[m.currentCategoryIndex]
    if index < 0 or index >= category.programs.Count() then return
    
    program = category.programs[index]
    
    LogInfo("GUIDE", "Program selected: " + program.title)
    
    ' TODO: Launch video player with the channel
    ' For now, just log
    if program.DoesExist("channel") and program.channel <> invalid then
        LogInfo("GUIDE", "Would play channel: " + program.channel.title)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    
    handled = false
    
    if key = "back" then
        if m.showingPrograms then
            ' Go back to categories
            HideProgramList()
            handled = true
        else
            ' Close guide view
            m.top.closed = true
            handled = true
        end if
    end if
    
    return handled
end function

sub HideProgramList()
    m.showingPrograms = false
    
    ' Hide program UI
    m.programBackground.visible = false
    m.programHeader.visible = false
    m.programList.visible = false
    
    ' Return focus to categories
    m.categoryList.setFocus(true)
    
    ' Restore help text
    m.helpLabel.text = "◀ ▶ Navigate categories  •  OK to view programs  •  ◀ Back to exit"
    
    LogInfo("GUIDE", "Returned to category view")
end sub
