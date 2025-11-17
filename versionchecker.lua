local function isVersionOutdated(v1, v2)
    local v1Nums = {}
    for value in string.gmatch(v1, "[^.]+") do
        v1Nums[#v1Nums+1] = tonumber(value)
    end

    local v2Nums = {}
    for value in string.gmatch(v2, "[^.]+") do
        v2Nums[#v2Nums+1] = tonumber(value)
    end

    for i = 1, #v1Nums do
        local outdated = (v1Nums[i] or 0) < (v2Nums[i] or 0)

        if (outdated) then
            return true
        end
    end

    return false
end

-- Complete response from the API for the "mini" endpoint
---@class VersionResponse
---@field project_name string
---@field version string
---@field type "free" | "paid"
---@field download_url string

---@return
---| { version: string, downloadUrl: string } // Current version & download URL for the project (Asset Portal / GitHub)
---| { code: integer } // Some form of error we report to the user
local function getLatestVersion()
    local p = promise.new()
    local endpoint = ("https://api.zykeresources.com/projects/%s/mini"):format(ResName)

    ---@param status integer
    ---@param result string | nil // JSON string or nil if the request failed
    PerformHttpRequest(endpoint, function(status, result)
        local decoded = result and json.decode(result) or nil
        if (not decoded) then p:resolve({code = status}) return end

        ---@cast decoded VersionResponse

        if (status == 200) then p:resolve({version = decoded.version, downloadUrl = decoded.download_url}) return end -- Success
        if (status == 429) then p:resolve({code = status}) return end -- Rate limit
        if (status == 404 or status == 500) then p:resolve({code = status}) return end -- Some form of error

        -- All other cases of miscellaneous errors
        p:resolve({code = status})
    end, "GET")

    return Citizen.Await(p)
end

---@return string
local function getCurrentVersion()
    return GetResourceMetadata(ResName, "version", 0)
end

---Checks and logs the version status for the resource
---@return boolean isOutdated @ If outdated
local function checkAndLog()
    local currVersion = getCurrentVersion()
    local latest = getLatestVersion()

    -- Handle API errors
    if (not latest.version) then
        print(("^3[%s] Could not fetch version, please contact discord.gg/zykeresources. (Error %s)^7"):format(ResName, latest.code))
        return false
    end

    local isOutdated = isVersionOutdated(currVersion, latest.version)

    if (isOutdated) then
        print("^3====================================================")
        print(("^3[%s] Your version is outdated! Please consider updating.^7\n"):format(ResName))
        print(("^1Current: %s^7"):format(currVersion))
        print(("^2Latest: %s^7"):format(latest.version))
        print(("^5Download: %s^7"):format(latest.downloadUrl))
        print("^3====================================================^7")
    else
        print("^2Your version is up to date!^7")
    end

    return isOutdated
end

-- Execute the check and log
checkAndLog()