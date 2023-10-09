Functions = {}
Tools = {}

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

-- Formatting the item(s) correctly, no matter what the input is
-- Used for item checking, adding and removing
function Functions.FormatItems(item, amount)
    local formatted = {}

    if (Framework == "QBCore") then
        if (type(item) == "string") then
            formatted[item] = amount or 1
        else
            if (item.name) or (item.item) then
                item = {item}
            end

            for k,v in pairs(item) do
                local _item = (type(v) == "number" and k) or v.name or v.item
                local _amount = (type(v) == "number" and v) or v.amount or v.count or 1

                formatted[_item] = formatted[_item] and formatted[_item] + _amount or _amount
            end
        end
    else
        if (type(item) == "string") then
            table.insert(formatted, {
                name = item,
                count = amount or 1
            })
        else
            if (item.name) or (item.item) then
                item = {item}
            end

            for k,v in pairs(item) do
                local _item = (type(v) == "number" and k) or v.name or v.item
                local _amount = (type(v) == "number" and v) or v.amount or v.count or 1

                table.insert(formatted, {
                    name = _item,
                    count = _amount
                })
            end
        end
    end

    return formatted
end

-- Add for offline characters
function Functions.FormatCharacterDetails(character, online)
    local formatted = {}

    if (Framework == "QBCore") then
        if (not character?.PlayerData) then
            return {}
        end

        formatted.identifier = character.PlayerData.citizenid
        formatted.source = character.PlayerData.source
        formatted.firstname = character.PlayerData.charinfo.firstname
        formatted.lastname = character.PlayerData.charinfo.lastname
        formatted.dateofbirth = character.PlayerData.charinfo.birthdate
        formatted.phonenumber = character.PlayerData.charinfo.phone
        formatted.nationality = character.PlayerData.charinfo.nationality
        formatted.backstory = character.PlayerData.charinfo.backstory
        formatted.cash = character.PlayerData.money["cash"] or 0
        formatted.bank = character.PlayerData.money["bank"] or 0
        formatted.dirty_cash = character.PlayerData.money["dirty_cash"] or 0
        formatted.online = online or false
        -- TODO: Match ESX (Future proofing)
    elseif (Framework == "ESX") then
        formatted.identifier = character.identifier
        formatted.source = character.source
        formatted.firstname = character.variables.firstName
        formatted.lastname = character.variables.lastName
        formatted.dateofbirth = character.variables.dateofbirth
        formatted.phonenumber = character.variables.phoneNumber
        formatted.backstory = nil -- By default there is none
        formatted.cash = character.accounts.money
        formatted.bank = character.accounts.bank
        formatted.dirty_cash = character.accounts.black_money
        formatted.online = online or false

        -- Unused, future proofing
        formatted.gender = character.variables.sex
        formatted.height = character.variables.height
        formatted.jobName = character.job.name
        formatted.jobLabel = character.job.label
        formatted.jobGrade = character.job.grade
        formatted.salary = character.job.grade_salary
    end

    return formatted
end

---@class FormattingOptions
---@field exclude table -- Array of identifiers that should be excluded {"identifier1", "identifier2"}, set to nil/{} to disable
---@field includeServerId boolean

---@param players table -- Array of player identifiers
---@param options FormattingOptions
---@return table -- Array of formatted players
function Functions.FormatPlayers(players, options)
    local playerDetails = Functions.GetPlayerDetails(players)
    local formattedPlayers = {}

    for _, playerDetail in pairs(playerDetails) do
        if ((options.exclude) and (#options.exclude > 0)) then
            local shouldBeExcluded = Functions.Contains(options.exclude, playerDetail.identifier)
            if (shouldBeExcluded) then goto setToEnd end
        end

        local firstname = playerDetail.firstname or "NOT FOUND"
        local lastname = playerDetail.lastname or "NOT FOUND"
        local label = firstname .. " " .. lastname

        if (options.includeServerId) then
            label = ("(%s) "):format(playerDetail.source or "X") .. label
        end

        table.insert(formattedPlayers, {
            label = label,
            name = playerDetail.identifier,
            value = playerDetail.identifier,
        })

        ::setToEnd::
    end

    return formattedPlayers
end

-- Note that this only formats, does not check if any values exist
function Functions.FormatJob(details)
    if (Framework == "QBCore") then
        local job = {
            name = details.name or "NAME NOT FOUND",
            label = details.label or "LABEL NOT FOUND",
            grade = {
                level = details.grade.level or "GRADE LEVEL NOT FOUND",
                name = details.grade.name or "GRADE NAME NOT FOUND"
            }
        }

        return job
    elseif (Framework == "ESX") then
        -- Untested
    end
end

function Functions.FormatGang(details)
    if (Framework == "QBCore") then
        local gang = {
            name = details.name or "NAME NOT FOUND",
            label = details.label or "LABEL NOT FOUND",
            grade = {
                level = details.grade.level or "GRADE LEVEL NOT FOUND",
                name = details.grade.name or "GRADE NAME NOT FOUND"
            }
        }

        return gang
    elseif (Framework == "ESX") then
        -- Untested
    end
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

function Functions.GetConfig()
    return Config
end

-- Only tested for QB
---@param name string -- Name of job
function Functions.GetJobDetails(name)
    while (Framework == nil) do Wait(100) end

    if (Framework == "QBCore") then
        local details = QBCore.Shared.Jobs[name]
        if (not details) then return nil end

        local job = {
            label = details.label
        }

        return job
    elseif (Framework == "ESX") then
        -- Untested
    else
        error("This job does not exist: " .. tostring(name))
    end
end

-- Only tested for QB
---@param name string -- Name of gang
function Functions.GetGangDetails(name)
    while (Framework == nil) do Wait(100) end

    if (Framework == "QBCore") then
        local details = QBCore.Shared.Gangs[name]
        if (not details) then return nil end

        local gang = {
            label = details.label
        }

        return gang
    elseif (Framework == "ESX") then
        -- Untested
    else
        error("This gang does not exist: " .. tostring(name))
    end
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
        -- TODO: Add this for ESX once needed
    end

    return nil
end