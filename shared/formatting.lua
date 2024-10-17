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
    if (character == nil) then return nil end

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
        -- TODO: Add position fetching
    elseif (Framework == "ESX") then
        formatted.identifier = character.identifier
        formatted.source = character.source
        formatted.firstname = character.firstname or character?.variables?.firstName
        formatted.lastname = character.lastname or character?.variables?.lastName
        formatted.dateofbirth = character.dateofbirth or character?.variables?.dateofbirth
        formatted.phonenumber = character.phone_number or character?.variables?.phoneNumber
        formatted.backstory = nil -- By default there is none
        formatted.cash = character.accounts.money
        formatted.bank = character.accounts.bank
        formatted.dirty_cash = character.accounts.black_money
        formatted.online = online or false

        -- Unused, future proofing
        formatted.gender = character.sex or character?.variables?.sex
        formatted.height = character.height or character?.variables?.height
        formatted.jobName = character.job or character?.job?.name
        formatted.jobLabel = character?.job?.label or "NON-EXISTENT"
        formatted.jobGrade = character.job_grade or character?.job?.grade
        formatted.salary = character?.job?.grade_salary or 0

        -- For some reason, sometimes it has keys in the character.accounts and sometimes not?
        if (formatted.cash == nil) then
            for _, account in pairs(character.accounts) do
                if (account.name == "bank") then
                    formatted.bank = account.money
                elseif (account.name == "money") then
                    formatted.cash = account.money
                end
            end
        end

        if (online) then
            -- Will not work when handled from client
            -- However, despite the file being shared it is never used on the client directly
            -- Usually send from client to fetch everything server-sided to have it synced

            local plyPed = GetPlayerPed(character.source)
            local plyPos = GetEntityCoords(plyPed)
            local w = GetEntityHeading(plyPed)

            formatted.position = {
                x = plyPos.x,
                y = plyPos.y,
                z = plyPos.z,
                w = w
            }
        else
            formatted.position = {
                x = character.position.x,
                y = character.position.y,
                z = character.position.z,
                w = character.position.heading
            }
        end
    end

    return formatted
end

---@class FormattingOptions
---@field exclude? table -- Array of identifiers that should be excluded {"identifier1", "identifier2"}, set to nil/{} to disable
---@field includeServerId? boolean | string -- Include %s which will be replaced with the id, allows custom formatting (%s., (%s), %s -)
---@field sortServerId? boolean -- Sort by server id, only works if includeServerId is true
---@field removeIfNil? boolean -- Simply remove if the value is nil, sometimes the list may contain values that are not players, instead of having to manually remove them and then add them, this removes them and you can later re-add them
---@field allowRepeatedIdentifiers? boolean -- Set to true to allow the same identifier to be added multiple times
---@field includeSteamName? boolean -- True to include their steam name
---@field idAsValue? boolean -- Set the value key to the server id
---@field includeLicense? boolean -- Includes the account license

---@param players table -- Array of player identifiers
---@param options FormattingOptions
---@return table -- Array of formatted players
function Functions.FormatPlayers(players, options)
    if ((not players) or (type(players) ~= "table")) then error("Players must be a table") end

    local playerDetails = Functions.GetPlayerDetails(players or {})
    local formattedPlayers = {}
    local addedIdentifiers = {}

    for _, playerDetail in pairs(playerDetails) do
        if (not playerDetail) then goto setToEnd end

        if (not options?.allowRepeatedIdentifiers) then
            if (addedIdentifiers[playerDetail.identifier]) then goto setToEnd end
            addedIdentifiers[playerDetail.identifier] = true
        end

        if (options?.removeIfNil) then
            if (playerDetail.firstname == nil) then goto setToEnd end
            if (playerDetail.lastname == nil) then goto setToEnd end
        end

        if ((options?.exclude) and (#options?.exclude > 0)) then
            local shouldBeExcluded = Functions.Contains(options?.exclude, playerDetail.identifier)
            if (shouldBeExcluded) then goto setToEnd end
        end

        local firstname = playerDetail.firstname or "NOT FOUND"
        local lastname = playerDetail.lastname or "NOT FOUND"
        local label = firstname .. " " .. lastname

        if (options?.includeServerId) then
            if (type(options.includeServerId) == "boolean") then
                label = ("(%s) "):format(playerDetail.source or "X") .. label
            elseif (type(options.includeServerId) == "string") then
                label = options.includeServerId:format(playerDetail.source) .. " " .. label
            end
        end

        table.insert(formattedPlayers, {
            label = label,
            name = playerDetail.identifier,
            value = options?.idAsValue and playerDetail.source or playerDetail.identifier,
            plyId = options?.includeServerId and playerDetail.source or nil,
            steamName = options?.includeSteamName and GetPlayerName(GetPlayerFromServerId(playerDetail.source)) or nil,
            license = options?.includeLicense and Player(playerDetail.source).state["zyke_lib:license"],
        })

        ::setToEnd::
    end

    if (#formattedPlayers > 1 and options?.includeServerId and options?.sortServerId) then
        table.sort(formattedPlayers, function(a, b)
            return a.plyId < b.plyId
        end)
    end

    return formattedPlayers
end

---@param details table
---@return table
function Functions.FormatJob(details)
    if (Framework == "QBCore") then
        local job = {
            name = details?.name or "NAME NOT FOUND",
            label = details?.label or "LABEL NOT FOUND",
            grade = {
                level = details?.grade?.level or "GRADE LEVEL NOT FOUND",
                name = details?.grade?.name or "GRADE NAME NOT FOUND"
            }
        }

        return job
    elseif (Framework == "ESX") then
        local job = {
            name = details?.name or "NAME NOT FOUND",
            label = details?.label or "LABEL NOT FOUND",
            grade = {
                level = details?.grade or "GRADE LEVEL NOT FOUND",
                name = details?.grade_name or "GRADE NAME NOT FOUND"
            }
        }

        return job
    end

    return {}
end

---@param details table
---@return table | nil
function Functions.FormatGang(details)
    if (Framework == "QBCore") then
        local gang = {
            name = details?.name or "NAME NOT FOUND",
            label = details?.label or "LABEL NOT FOUND",
            grade = {
                level = details?.grade?.level or "GRADE LEVEL NOT FOUND",
                name = details?.grade?.name or "GRADE NAME NOT FOUND"
            }
        }

        return gang
    elseif (Framework == "ESX") then
        if (GangScript == "zyke_gangphone") then
            local gang = {
                name = details?.id or "NAME NOT FOUND",
                label = details?.name or "LABEL NOT FOUND",
                grade = {
                    name = details?.rank?.name or "GRADE LEVEL NOT FOUND",
                    level = details?.rank?.level or "GRADE NAME NOT FOUND"
                }
            }

            return gang
        end

        return nil
    end
end

---@param details table
---@return table
-- Note that the grade level is one higher, this is to fit the indexing for LUA
function Functions.FormatJobDetails(details)
    if (Framework == "QBCore") then
        local grades = {}

        for key, value in pairs(details.grades) do
            grades[tonumber(key) + 1] = {
                name = value.name,
                label = value.name, -- No label, just set the name
                boss = value.isboss
            }
        end

        return {
            name = details.name,
            label = details.label,
            grades = grades,
        }
    elseif (Framework == "ESX") then
        local grades = {}

        local highestGrade = 1
        for key, value in pairs(details.grades) do
            local grade = tonumber(key) + 1

            if (grade > highestGrade) then
                highestGrade = grade
            end

            grades[grade] = {
                name = value.name,
                label = value.label,
                boss = false
            }
        end

        grades[highestGrade].boss = true

        return {
            name = details.name,
            label = details.label,
            grades = grades,
        }
    end

    return {}
end

---@param details table
---@return table
-- Note that the grade level is one higher, this is to fit the indexing for LUA
function Functions.FormatGangDetails(details)
    if (Framework == "QBCore") then
        local grades = {}

        for key, value in pairs(details.grades) do
            grades[tonumber(key) + 1] = {
                name = value.name,
                label = value.name, -- No label, just set the name
                boss = value.isboss
            }
        end

        return {
            name = details.name,
            label = details.label,
            grades = grades,
        }
    elseif (Framework == "ESX") then
        if (GangScript == "zyke_gangphone") then
            local grades = {}
            for idx, value in pairs(details.ranks) do
                grades[idx] = {
                    name = value.name,
                    label = value.label,
                    boss = idx == 1
                }
            end

            return {
                name = details.id,
                label = details.label or details.name,
                grades = grades
            }
        end
    end

    return {}
end

-- TODO: Verify the bundling, it seems to only be part of zyke_catalytic, which is not released yet
---@class FormattedItem
---@field name string
---@field label string
---@field amount integer
---@field weight number
---@field metadata table<string, any> | nil
---@field slot integer

---@param tbl table
---@param disableBundling boolean?
---@return FormattedItem | FormattedItem[]
function Functions.FormatItemsFetch(tbl, disableBundling)
    local isArray = Functions.IsArray(tbl)

    if (isArray) then
        ---@type FormattedItem[]
        local formatted = {}

        ---@type table<string, integer> @Item name, idx
        local itemIdxs = {}

        for i, itemData in pairs(tbl) do
            local item = Functions.FormatItemsFetch(itemData, disableBundling)

            if (disableBundling) then
                formatted[#formatted+1] = item -- Simply insert if no bundling
            else
                -- If bundling...
                local existingIdx = itemIdxs[item.name]

                if (existingIdx) then
                    formatted[existingIdx].amount += item.amount -- If item exists, add the amounts together
                else
                    formatted[#formatted+1] = item -- Add the new item
                    itemIdxs[item.name] = #formatted -- Register the index
                end
            end
        end

        return formatted
    end

    ---@type FormattedItem
    local formatted = {
        name = tbl.name,
        label = tbl.label,
        amount = tbl.amount or tbl.count,
        weight = tbl.weight,
        metadata = tbl.metadata or tbl.info,
        slot = tbl.slot,
    }

    return formatted
end