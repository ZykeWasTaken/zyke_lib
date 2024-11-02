-- TODO: Probably outdated?
local resName = GetCurrentResourceName()

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
    local repoName = resName
    local endpoint = ("http://localhost:3000/fxmanifest?repo=%s"):format(repoName)

    PerformHttpRequest(endpoint, function(resCode, resultData)
        -- print("resCode", resCode)
        -- print("resultData", resultData)

        -- Found repo & got info
        if (resCode == 200) then
            local latestVersion = resultData:match("version%s\"(%d+%.%d+%.%d+)\"")
            p:resolve({version = latestVersion, code = resCode})
        else
            -- Could not find repository or file during version check
            p:resolve({version = nil, code = resCode})
        end
    end)

    return Citizen.Await(p)
end

---@return string
local function getCurrentVersion()
    return GetResourceMetadata(resName, "version", 0)
end

CreateThread(function()
    local currVersion = getCurrentVersion()

    local latestVersion = getLatestVersion()
    if (not latestVersion.version) then
        error("Could not access resource repository, contact the developer of this resource! Code: " .. latestVersion.code)
    end

    local isOutdated = isVersionOutdated(currVersion, latestVersion.version)
    print("isOutdated", isOutdated)
end)
