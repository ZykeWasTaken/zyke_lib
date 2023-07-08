Functions = {}

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

-- Formatting the item(s) correctly, no matter what the input is
-- Used for item checking, adding and removing
function Functions.FormatItems(item, amount)
    local formatted = {}

    if (Config.Framework == "QBCore") then
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

    if (Config.Framework == "QBCore") then
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
    elseif (Config.Framework == "ESX") then
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

function Functions.GetItem(item)
    if (Config.Framework == "QBCore") then
        return QBCore.Shared.Items[item]
    elseif (Config.Framework == "ESX") then
        return ESX.Items[item]
    end
end

function Functions.GetFramework()
    return Config.Framework
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

CreateThread(function()
    local availableFrameworks = {
        ["ESX"] = true,
        ["QBCore"] = true
    }

    if (not availableFrameworks[Config.Framework]) then
        error("Invalid framework specified in config.lua, make sure to use a supported framework!")
    end
end)