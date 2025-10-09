function FetchTextResource(url as string, options = invalid) as object
    response = {
        success: false,
        statusCode: 0,
        body: "",
        headers: CreateObject("roAssociativeArray"),
        error: invalid,
        attempts: 0
    }

    if url = invalid or url.Trim() = "" then
        response.error = "Empty URL"
        return response
    end if

    if Left(LCase(url), 5) = "file:" then
        return FetchLocalFile(url)
    end if

    retries = 2
    timeoutMs = 10000
    if options <> invalid then
        if options.DoesExist("retries") then retries = options.retries
        if options.DoesExist("timeout") then timeoutMs = options.timeout
    end if

    for attempt = 0 to retries
        response.attempts = response.attempts + 1
        transfer = CreateObject("roUrlTransfer")
        transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
        transfer.SetURL(url)
        transfer.SetRequest("GET")
        transfer.SetMinimumTransferRate(1, timeoutMs)

        if options <> invalid and options.DoesExist("headers") then
            headers = options.headers
            for each key in headers
                transfer.AddHeader(key, headers[key])
            end for
        end if

        ' SetUserAgent not available in Task context, skip it
        ' if options <> invalid and options.DoesExist("userAgent") then
        '     transfer.SetUserAgent(options.userAgent)
        ' end if

        result = transfer.GetToString()
        
        ' In Task context, GetResponseCode() and GetResponseHeaders() are not available
        ' If we got a result, assume success
        if result <> invalid and Len(result) > 0 then
            response.success = true
            response.statusCode = 200
            response.body = result
            return response
        else
            response.error = "Empty or invalid response"
            if attempt < retries then
                Sleep(100 * (attempt + 1) * (attempt + 1))
            end if
        end if
    end for

    return response
end function

function FetchLocalFile(url as string) as object
    response = {
        success: false,
        statusCode: 0,
        body: "",
        headers: CreateObject("roAssociativeArray"),
        error: invalid,
        attempts: 1
    }

    path = url
    if Left(url.ToLower(), 7) = "file://" then
        path = Mid(url, 8)
    end if

    data = ReadAsciiFile(path)
    if data <> invalid then
        response.success = true
        response.body = data
        response.statusCode = 200
    else
        response.error = "Failed to read file: " + path
    end if

    return response
end function
