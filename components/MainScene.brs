sub init()
    ' Get references to UI elements
    m.welcomeLabel = m.top.FindNode("welcomeLabel")
    m.instructionLabel = m.top.FindNode("instructionLabel")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.contentGroup = m.top.FindNode("contentGroup")
    
    ' Set focus to scene to handle input
    m.top.setFocus(true)
    
    ' Set up key handler
    m.top.observeField("focusedChild", "onFocusChanged")
    
    ' Update status
    m.statusLabel.text = "Ready - Press any key"
    
    print "MainScene initialized successfully"
    print "Scene size: "; m.top.width; "x"; m.top.height
    
    ' Start a simple animation to show the app is responsive
    animateWelcome()
end sub

sub animateWelcome()
    ' Simple fade-in animation for welcome text
    if m.welcomeLabel <> invalid
        animation = createObject("roSGNode", "Animation")
        animation.duration = 1.0
        animation.easeFunction = "inOutCubic"
        
        interpolator = createObject("roSGNode", "FloatFieldInterpolator")
        interpolator.key = [0.0, 1.0]
        interpolator.keyValue = [0.0, 1.0]
        interpolator.fieldToInterp = "welcomeLabel.opacity"
        
        animation.appendChild(interpolator)
        m.contentGroup.appendChild(animation)
        animation.control = "start"
        
        print "Welcome animation started"
    end if
end sub

sub onFocusChanged()
    print "Focus changed in MainScene"
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press
        print "Key pressed in MainScene: "; key
        
        if key = "OK" or key = "play"
            m.statusLabel.text = "OK button pressed!"
            m.instructionLabel.text = "Navigation will be added here"
            return true
        else if key = "back"
            m.statusLabel.text = "Back button pressed"
            return true
        else if key = "options"
            m.statusLabel.text = "Options button pressed"
            return true
        else
            m.statusLabel.text = "Key pressed: " + key
        end if
    end if
    
    return false
end function
