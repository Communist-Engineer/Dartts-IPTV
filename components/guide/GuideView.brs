sub init()
    LogInfo("GUIDE", "Initializing Guide View")
    
    ' Make this component focusable to receive key events
    m.top.setFocus(true)
    
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
        LogInfo("GUIDE", "Added category: " + categoryName + " with " + Str(programs.Count()) + " programs")
    end for
    
    LogInfo("GUIDE", "Built " + Str(m.categories.Count()) + " categories")
    
    ' Populate category list - LabelList structure: simple list with title field
    content = CreateObject("roSGNode", "ContentNode")
    
    LogInfo("GUIDE", "Creating content nodes for LabelList (simple category list)")
    itemIndex = 0
    for each cat in m.categories
        item = content.CreateChild("ContentNode")
        ' Format category with count for display
        item.title = cat.category + " (" + Str(cat.count) + " live now)"
        ' Store category data for selection
        item.addFields({categoryData: cat})
        LogInfo("GUIDE", "Category " + Str(itemIndex) + ": " + item.title)
        itemIndex = itemIndex + 1
    end for
    
    LogInfo("GUIDE", "Content has " + Str(content.getChildCount()) + " categories")
    LogInfo("GUIDE", "Setting content on categoryList (LabelList)")
    m.categoryList.content = content
    if m.categoryList.content = invalid then
        LogInfo("GUIDE", "ERROR: Content set failed - categoryList.content is invalid")
    else
        LogInfo("GUIDE", "Content set successfully")
    end if
    
    visibleStr = "false"
    if m.categoryList.visible then visibleStr = "true"
    LogInfo("GUIDE", "categoryList visible: " + visibleStr)
    
    focusableStr = "false"
    if m.categoryList.focusable then focusableStr = "true"
    LogInfo("GUIDE", "categoryList focusable: " + focusableStr)
    
    LogInfo("GUIDE", "Setting focus to categoryList")
    m.categoryList.setFocus(true)
    if m.categoryList.hasFocus() then
        LogInfo("GUIDE", "categoryList has focus: YES")
    else
        LogInfo("GUIDE", "categoryList has focus: NO")
    end if
    
    LogInfo("GUIDE", "Category list populated with " + Str(content.getChildCount()) + " items")
end sub

sub OnCategorySelected()
    ' LabelList itemSelected returns an integer index
    itemIndex = m.categoryList.itemSelected
    if itemIndex = invalid or itemIndex < 0 then return
    
    LogInfo("GUIDE", "OnCategorySelected: itemIndex = " + Str(itemIndex))
    
    if itemIndex >= m.categories.Count() then
        LogInfo("GUIDE", "Invalid item index: " + Str(itemIndex) + ", max is " + Str(m.categories.Count() - 1))
        return
    end if
    
    m.currentCategoryIndex = itemIndex
    category = m.categories[itemIndex]
    
    LogInfo("GUIDE", "Category selected: " + category.category + " with " + Str(category.count) + " programs")
    
    ' Show program list
    ShowProgramList(category)
end sub

sub ShowProgramList(category as object)
    LogInfo("GUIDE", "ShowProgramList() called for category: " + category.category)
    m.showingPrograms = true
    
    ' Update header
    m.programHeader.text = category.category + " - Live Now"
    LogInfo("GUIDE", "Header text set")
    
    ' Build program content for LabelList (uses title field only)
    content = CreateObject("roSGNode", "ContentNode")
    LogInfo("GUIDE", "Building program list for " + Str(category.programs.Count()) + " programs")
    
    programIndex = 0
    for each program in category.programs
        item = content.CreateChild("ContentNode")
        ' Format program info as a single line for LabelList
        programText = program.channelName + ": " + program.title
        if program.description <> "" and Len(program.description) > 0 then
            programText = programText + " - " + program.description
        end if
        item.title = programText
        ' Store program data for selection using addFields
        item.addFields({programData: program})
        LogInfo("GUIDE", "Program " + Str(programIndex) + ": " + programText)
        programIndex = programIndex + 1
    end for
    
    LogInfo("GUIDE", "Setting program list content with " + Str(content.getChildCount()) + " items")
    m.programList.content = content
    
    ' Show program UI
    LogInfo("GUIDE", "Making program UI visible")
    m.programBackground.visible = true
    m.programHeader.visible = true
    m.programList.visible = true
    
    ' Give focus to program list
    LogInfo("GUIDE", "Setting focus to program list")
    m.programList.setFocus(true)
    m.programList.jumpToItem = 0
    
    ' Update help text
    m.helpLabel.text = "◀ Back to categories  •  OK to play channel"
    
    LogInfo("GUIDE", "ShowProgramList() complete - showing " + Str(category.programs.Count()) + " programs")
end sub

sub OnProgramSelected()
    if not m.showingPrograms then return
    
    index = m.programList.itemSelected
    if index < 0 then return
    
    ' Get the program data from the content node
    content = m.programList.content
    if content = invalid or content.getChildCount() = 0 then return
    if index >= content.getChildCount() then return
    
    item = content.getChild(index)
    if item = invalid or not item.DoesExist("programData") then return
    
    program = item.programData
    
    LogInfo("GUIDE", "Program selected: " + program.title)
    
    ' Launch video player with the channel
    if program.DoesExist("channel") and program.channel <> invalid then
        LogInfo("GUIDE", "Playing channel: " + program.channel.title)
        PlayChannel(program.channel)
    else
        LogInfo("GUIDE", "No channel data for this program")
    end if
end sub

sub PlayChannel(channel as object)
    LogInfo("GUIDE", "PlayChannel() called for: " + channel.title)
    
    ' Get the parent scene (HomeScene or AppScene)
    parentScene = m.top.GetParent()
    if parentScene = invalid then
        LogInfo("GUIDE", "ERROR: Cannot get parent scene")
        return
    end if
    
    LogInfo("GUIDE", "Parent scene found")
    
    ' Find or create the video player
    videoPlayer = parentScene.FindNode("videoPlayerScene")
    if videoPlayer = invalid then
        LogInfo("GUIDE", "Creating new VideoPlayerScene")
        videoPlayer = CreateObject("roSGNode", "VideoPlayerScene")
        videoPlayer.id = "videoPlayerScene"
        parentScene.appendChild(videoPlayer)
        
        ' Observe when player wants to close
        videoPlayer.ObserveField("closeRequested", "OnPlayerCloseRequested")
    else
        LogInfo("GUIDE", "Found existing VideoPlayerScene")
    end if
    
    ' Hide the guide
    m.top.visible = false
    LogInfo("GUIDE", "Guide hidden")
    
    ' Show and start the player with the selected channel
    videoPlayer.visible = true
    videoPlayer.channel = channel
    videoPlayer.setFocus(true)
    
    LogInfo("GUIDE", "Video player launched for: " + channel.title)
end sub

sub OnPlayerCloseRequested()
    LogInfo("GUIDE", "OnPlayerCloseRequested() called")
    
    ' Player wants to close - show guide again
    parentScene = m.top.GetParent()
    if parentScene = invalid then return
    
    videoPlayer = parentScene.FindNode("videoPlayerScene")
    if videoPlayer <> invalid then
        videoPlayer.visible = false
        LogInfo("GUIDE", "Video player hidden")
    end if
    
    ' Show guide and restore focus
    m.top.visible = true
    if m.showingPrograms and m.programList <> invalid then
        m.programList.setFocus(true)
        LogInfo("GUIDE", "Returned to guide (program list)")
    else if m.categoryList <> invalid then
        m.categoryList.setFocus(true)
        LogInfo("GUIDE", "Returned to guide (category list)")
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    
    showingStr = "false"
    if m.showingPrograms then showingStr = "true"
    LogInfo("GUIDE", "Key event: " + key + ", showing programs: " + showingStr)
    
    handled = false
    
    if key = "back" then
        if m.showingPrograms then
            ' Go back to categories
            LogInfo("GUIDE", "Back pressed - hiding program list")
            HideProgramList()
            handled = true
        else
            ' Close guide view
            LogInfo("GUIDE", "Back pressed - closing guide")
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
