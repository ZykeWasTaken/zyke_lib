function Functions.CopyTable(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = Functions.CopyTable(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function Functions.Debug(msg, enabled)
    enabled = enabled or Config.Debug

    if (enabled == true) then
        print("^4[Debug]: ^7" .. msg)
    end
end

function Functions.CountTable(tbl)
    if (not tbl) then Functions.Debug(GetInvokingResource() .. " tried to count a nil table", Config.Debug) return 0 end
    local count = 0

    for k, v in pairs(tbl) do
        count = count + 1
    end

    return count
end

---@param tbl table -- Needs to be an array
---@param desiredString string
---@return boolean, number | nil
function Functions.Contains(tbl, desiredString)
    if (not tbl) then error("Attempt to scan non-existens table") end

    for idx, string in pairs(tbl) do
        if (desiredString == string) then
            return true, idx
        end
    end

    return false, nil
end

---@param tbl table
---@param predicate function
---@return any, number | string | nil
function Functions.Find(tbl, predicate)
    if (not tbl) or (type(tbl) ~= "table") then error("Attempt to scan non-existent table") end

    for key, value in pairs(tbl) do
        if (predicate(value)) then
            return value, key
        end
    end

    return nil, nil
end

function Functions.GetItem(item)
    if (Framework == "QBCore") then
        return QBCore.Shared.Items[item]
    elseif (Framework == "ESX") then
        return ESX.Items[item]
    end
end

function Functions.GetFramework()
    while (Framework == nil or Framework == "") do Wait(10) end
    return Framework
end

function Functions.GetWeaponType()
    return Config.WeaponType
end

function Functions.GetTarget()
    return Config.Target
end

function Functions.GetBlipColors()
    return Config.BlipColors
end

function Functions.GetConfig()
    return Config
end

---@param name string -- Name of job
function Functions.GetJobDetails(name)
    while (Framework == nil) do Wait(100) end

    if (Framework == "QBCore") then
        local details = Functions.GetJobData(name)
        if (not details) then return nil end

        details.name = name -- Name is not included, so we'll add it in

        return Functions.FormatJobDetails(details)
    elseif (Framework == "ESX") then
        local details = Functions.GetJobData(name)
        if (not details) then return nil end

        details.name = name -- Name is not included, so we'll add it in

        return Functions.FormatJobDetails(details)
    end
end

-- Only tested for QB
---@param name string -- Name of gang
function Functions.GetGangDetails(name)
    while (Framework == nil) do Wait(100) end

    if (Framework == "QBCore") then
        local details = QBCore.Shared.Gangs[name]
        if (not details) then return nil end

        details.name = name -- Name is not included, so we'll add it in

        return Functions.FormatGangDetails(details)
    elseif (Framework == "ESX") then
        -- Untested (Not needed for any active releases)
        if (Config.GangScript == "zyke_gangphone") then
            local details = Functions.GetGangData(name)
            if (not details) then return nil end

            details.name = name -- Name is not included, so we'll add it in

            return Functions.FormatGangDetails(details)
        end
    end
end

---@param identifier string
---@return table | nil
function Functions.GetGangData(identifier)
    while (Framework == nil) do Wait(100) end

    if (Framework == "QBCore") then
        return QBCore.Shared.Gangs[identifier]
    elseif (Framework == "ESX") then
        if (Config.GangScript == "zyke_gangphone") then
            return exports["zyke_gangphone"]:GetGang(identifier)
        end
    end

    return nil
end

-- Only tested for QB (Not active in any releases yet)
---@param name string -- Job/gang name
---@param rankType string -- "job" / "gang"
---@return table | nil -- name = true, as some servers support multiple bosses, nil if no job/gang is found
function Functions.GetBossRanks(name, rankType)
    if (Framework == "QBCore") then
        if (rankType == "job") then
            local sortedList = {}
            local job = QBCore.Shared.Jobs[name]
            if (not job) then return nil end

            for _, details in pairs(job.grades) do
                if (details.isboss == true) then
                    sortedList[details.name] = true
                end
            end

            return sortedList
        elseif (rankType == "gang") then
            local sortedList = {}
            local gang = QBCore.Shared.Gangs?[name]
            if (not gang) then return nil end

            for _, details in pairs(gang.grades) do
                if (details.isboss == true) then
                    sortedList[details.name] = true
                end
            end

            return sortedList
        end
    elseif (Framework == "ESX") then
        if (rankType == "job") then
            local job = Functions.GetJobData(name)
            if (not job) then return nil end

            local highestGrade = 1
            local highestKey = nil
            for key, value in pairs(job.grades) do
                local grade = tonumber(key) or 0

                if (grade > highestGrade) then
                    highestGrade = grade
                    highestKey = key
                end
            end

            return {
                [job.grades[highestKey].name] = true
            }
        elseif (rankType == "gang") then
            if (Config.GangScript == "zyke_gangphone") then
                local gang = Functions.GetGangData(name)
                -- TODO
            end

            return nil
        end
    end

    return nil
end

function Functions.GetRandomDictionaryKey(tbl)
    local keys = {}

    for key, _ in pairs(tbl) do
        keys[#keys+1] = key
    end

    return keys[math.random(1, #keys)]
end

---@param tbl table
---@return boolean
function Functions.IsArray(tbl)
    if (next(tbl) == nil) then
        return false
    end

    for key in pairs(tbl) do
        if (type(key) ~= "number") then
            return false
        end
    end

    return true
end

function Functions.HasLoadedFramework()
    if (Framework == "QBCore") then
        return QBCore ~= nil
    elseif (Framework == "ESX") then
        return ESX ~= nil
    end
end

---@param playerId number
function Functions.GetLicense(playerId)
    return Player(playerId).state["zyke_lib:license"]
end

---@param job string
---@return table | nil
function Functions.GetJobData(job)
    while (Framework == nil) do Wait(100) end

    if (Framework == "QBCore") then
        return QBCore.Shared.Jobs[job]
    elseif (Framework == "ESX") then
        local isServer = IsDuplicityVersion()
        return (isServer and ESX.GetJobs() or Functions.Callback("zyke_lib:ESX:FetchJobs", false))[job]
    end

    return nil
end