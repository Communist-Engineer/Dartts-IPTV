sub TestM3UParser()
    print "====== M3U Parser Tests ======"
    
    TestBasicM3U()
    TestM3UWithGroups()
    TestM3UMissingHeader()
    TestM3UMalformedEntries()
    TestM3UUnicodeHandling()
    
    print "====== M3U Parser Tests Complete ======"
end sub

sub TestBasicM3U()
    print "Test: Basic M3U parsing"
    
    content = "#EXTM3U" + Chr(10)
    content = content + "#EXTINF:-1,Test Channel" + Chr(10)
    content = content + "http://example.com/stream.m3u8" + Chr(10)
    
    result = ParseM3U(content)
    
    AssertEqual(result.channels.Count(), 1, "Should parse 1 channel")
    AssertEqual(result.channels[0].name, "Test Channel", "Channel name should match")
    AssertEqual(result.channels[0].streamUrl, "http://example.com/stream.m3u8", "Stream URL should match")
    
    print "✓ Basic M3U parsing passed"
end sub

sub TestM3UWithGroups()
    print "Test: M3U with groups"
    
    content = "#EXTM3U" + Chr(10)
    content = content + "#EXTINF:-1 tvg-id=""test1"" group-title=""Sports"",Sports Channel" + Chr(10)
    content = content + "http://example.com/sports.m3u8" + Chr(10)
    content = content + "#EXTINF:-1 tvg-id=""test2"" group-title=""News"",News Channel" + Chr(10)
    content = content + "http://example.com/news.m3u8" + Chr(10)
    
    result = ParseM3U(content)
    
    AssertEqual(result.channels.Count(), 2, "Should parse 2 channels")
    AssertEqual(result.groups.Count(), 2, "Should have 2 groups")
    AssertTrue(result.groups.DoesExist("Sports"), "Should have Sports group")
    AssertTrue(result.groups.DoesExist("News"), "Should have News group")
    
    print "✓ M3U with groups passed"
end sub

sub TestM3UMissingHeader()
    print "Test: M3U missing header"
    
    content = "#EXTINF:-1,No Header Channel" + Chr(10)
    content = content + "http://example.com/stream.m3u8" + Chr(10)
    
    result = ParseM3U(content)
    
    AssertTrue(result.errors.Count() > 0, "Should have error for missing header")
    AssertEqual(result.channels.Count(), 1, "Should still parse channel")
    
    print "✓ M3U missing header passed"
end sub

sub TestM3UMalformedEntries()
    print "Test: M3U malformed entries"
    
    content = "#EXTM3U" + Chr(10)
    content = content + "http://orphan-url.com/stream.m3u8" + Chr(10)
    content = content + "#EXTINF:-1,Good Channel" + Chr(10)
    content = content + "http://example.com/good.m3u8" + Chr(10)
    
    result = ParseM3U(content)
    
    AssertEqual(result.channels.Count(), 2, "Should parse both entries")
    AssertTrue(result.errors.Count() > 0, "Should have error for orphan URL")
    
    print "✓ M3U malformed entries passed"
end sub

sub TestM3UUnicodeHandling()
    print "Test: M3U unicode handling"
    
    content = "#EXTM3U" + Chr(10)
    content = content + "#EXTINF:-1,Chaine Française" + Chr(10)
    content = content + "http://example.com/french.m3u8" + Chr(10)
    
    result = ParseM3U(content)
    
    AssertEqual(result.channels.Count(), 1, "Should parse unicode channel")
    
    print "✓ M3U unicode handling passed"
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

sub AssertFalse(condition as boolean, message as string)
    if condition then
        print "✗ FAIL: " + message
    end if
end sub
