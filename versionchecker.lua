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

---@return table{version: string, code: number}
local function getLatestVersion()
    local p = promise.new()
    local endpoint = ("https://api.zykeresources.com/projects/%s/mini"):format(ResName)

    PerformHttpRequest(endpoint, function(status, result)
        if (status == 200) then p:resolve({version = json.decode(result).version}) return end -- Success
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

local currVersion = getCurrentVersion()
local latestVersion = getLatestVersion()

if (not latestVersion.version) then return latestVersion.code end

return isVersionOutdated(currVersion, latestVersion.version), currVersion, latestVersion.version