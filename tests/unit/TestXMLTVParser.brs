sub TestXMLTVParser()
    print "====== XMLTV Parser Tests ======"
    
    TestBasicXMLTV()
    TestXMLTVNowNext()
    TestXMLTVMissingFields()
    
    print "====== XMLTV Parser Tests Complete ======"
end sub

sub TestBasicXMLTV()
    print "Test: Basic XMLTV parsing"
    
    content = "<?xml version=""1.0"" encoding=""UTF-8""?>"
    content = content + "<tv>"
    content = content + "<channel id=""test1""><display-name>Test Channel</display-name></channel>"
    content = content + "<programme start=""20251007120000 +0000"" stop=""20251007130000 +0000"" channel=""test1"">"
    content = content + "<title>Test Program</title>"
    content = content + "<desc>Test description</desc>"
    content = content + "</programme>"
    content = content + "</tv>"
    
    result = ParseXMLTV(content, invalid)
    
    AssertEqual(result.channels.Count(), 1, "Should parse 1 channel")
    AssertEqual(result.programs.Count(), 1, "Should parse 1 program set")
    
    print "✓ Basic XMLTV parsing passed"
end sub

sub TestXMLTVNowNext()
    print "Test: XMLTV now/next computation"
    
    content = "<?xml version=""1.0"" encoding=""UTF-8""?>"
    content = content + "<tv>"
    content = content + "<channel id=""test1""><display-name>Test</display-name></channel>"
    content = content + "</tv>"
    
    result = ParseXMLTV(content, invalid)
    
    AssertTrue(result.nowNext <> invalid, "Should have nowNext structure")
    
    print "✓ XMLTV now/next passed"
end sub

sub TestXMLTVMissingFields()
    print "Test: XMLTV missing fields"
    
    content = "<?xml version=""1.0"" encoding=""UTF-8""?>"
    content = content + "<tv>"
    content = content + "<programme start=""20251007120000 +0000"" stop=""20251007130000 +0000"">"
    content = content + "<title>Orphan Program</title>"
    content = content + "</programme>"
    content = content + "</tv>"
    
    result = ParseXMLTV(content, invalid)
    
    AssertTrue(result.errors.Count() > 0, "Should have error for missing channel attribute")
    
    print "✓ XMLTV missing fields passed"
end sub

sub AssertEqual(actual as dynamic, expected as dynamic, message as string)
    if actual <> expected then
        print "✗ FAIL: " + message
        print "  Expected: " + Box(expected).ToStr()
        print "  Actual:   " + Box(actual).ToStr()
    end if
end sub

sub AssertTrue(condition as boolean, message as string)
    if not condition then
        print "✗ FAIL: " + message
    end if
end sub
