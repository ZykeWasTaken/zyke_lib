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

-- Parses the unique server address from the Nucleus-assigned web_baseUrl convar
-- ex. "zyke-hijfdc.users.cfx.re" -> "hijfdc"
---@return string | nil
local function getServerAddress()
    -- Get the web_baseUrl convar, returning something along the lines of "zyke-hijfdc.users.cfx.re", with your Cfx username tied to the license key & server address
    local baseUrl = GetConvar("web_baseUrl", "")
    if (baseUrl == "") then return nil end

    -- Strip the known suffix
    local stripped = baseUrl:gsub("%.users%.cfx%.re$", "")

    -- Grab everything after the last dash
    return stripped:match(".*%-(.+)$")
end

-- Complete response from the API for the "mini" endpoint
---@class VersionResponse
---@field project_name string
---@field version string
---@field type "free" | "paid"
---@field download_url string

---@class UnknownProjectResponse
---@field error string
---@field code "PROJECT_NOT_FOUND"

---@param currVersion string @ Provide your current version
---@return
---| { version: string, downloadUrl: string } // Current version & download URL for the project (Asset Portal / GitHub)
---| { status: integer, code?: string } // Some form of error we report to the user
local function getLatestVersion(currVersion)
    local p = promise.new()
    local endpoint = ("https://api.zykeresources.com/projects/%s/mini"):format(ResName)

    ---@param status integer
    ---@param body string | nil
    ---@param headers table
    ---@param errorData string | nil
    PerformHttpRequest(endpoint, function(status, body, headers, errorData)
        local decoded
        if (body) then
            decoded = json.decode(body)
        elseif (errorData) then
            -- errorData seems to have a prefix of `HTTP 404: ` if we get a standard error
            -- Find the actual start of the json data
            local start = errorData:find("{")

            if (start) then
                local clean = errorData:sub(start)

                decoded = json.decode(clean)
            end
        end

        if (not decoded) then p:resolve({status = status}) return end

        ---@cast decoded VersionResponse | UnknownProjectResponse

        if (status == 200) then p:resolve({version = decoded.version, downloadUrl = decoded.download_url}) return end -- Success
        if (status == 429) then p:resolve({status = status}) return end -- Rate limit
        if (status == 404 or status == 500) then p:resolve({status = status, code = decoded.code}) return end -- Some form of error

        -- All other cases of miscellaneous errors
        p:resolve({status = status})
    end, "GET", "", {
        -- Submit version analytics, this just helps us to see how many people are using our scripts & their versions
        ["X-Client-Version"] = currVersion,
        ["X-Server-Address"] = getServerAddress()
    })

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
    local latest = getLatestVersion(currVersion)

    if (latest.code == "PROJECT_NOT_FOUND") then return false end

    -- Handle API errors
    if (not latest.version) then
        print(("^3[%s] Could not fetch version, please contact discord.gg/zykeresources. (Status: %s | Code: %s)^7"):format(ResName, latest.status, latest.code))
        return false
    end

    local isOutdated = isVersionOutdated(currVersion, latest.version)

    if (isOutdated) then
        local info = {
            ("^3[%s] Your version is outdated! Please consider updating.^7"):format(ResName),
            "",
            ("^1Current: %s^7"):format(currVersion),
            ("^2Latest: %s^7"):format(latest.version),
            ("^5Download: %s^7"):format(latest.downloadUrl)
        }

        local longestStr = 0
        for i = 1, #info do
            local stripped = info[i]:gsub("%^%d", "")
            local strLen = #stripped

            if (strLen > longestStr) then
                longestStr = strLen
            end
        end

        local topBorder = "^3╔" .. string.rep("═", longestStr + 2) .. "╗^7"
        local bottomBorder = "^3╚" .. string.rep("═", longestStr + 2) .. "╝^7"

        print(topBorder)
        for i = 1, #info do
            local stripped = info[i]:gsub("%^%d", "")
            local padding = string.rep(" ", longestStr - #stripped)

            print("^3║^7 " .. info[i] .. padding .. " ^3║^7")
        end
        print(bottomBorder)
    else
        print("^2Your version is up to date!^7")
    end

    return isOutdated
end

-- Execute the check and log
SetTimeout(1000, function()
    checkAndLog()
end)