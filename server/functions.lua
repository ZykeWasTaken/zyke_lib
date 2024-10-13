local function inventoryCompWarning()
    error("A function has been triggered that does not exist for your inventory, or does not exist by default.")
    error("If you inventory supports the function, but the base of your framework does not, please manually install it in zyke_lib.")
    error("If your inventory does not support this function, please refer to the compatibility requirements for this resource.")
end

-- Chacking player details
-- Note that the player identifiers such as Discord id can not be guaranteed
---@class HandlerDetails
---@field firstname string
---@field lastname string
---@field identifier string
---@field source integer
---@field steamid string?
---@field license string?
---@field discord string?
---@field xbl string?
---@field liveid string?
---@field ip string?

---@type table<string, HandlerDetails>
local handlers = {}

---@param scriptName string
---@param action string
---@param handler string | integer | "server" @Identifier, player id, "server"
---@param message string
---@param rawData table | nil
---@param webhook string? @Deprecated, kept for support
local function sendLog(scriptName, action, handler, message, rawData, webhook)
    ---@param resName string
    ---@param _action string
    ---@param providedUrl string? @Deprecated, storing all webhooks in zyke_lib now
    local function getWebhook(resName, _action, providedUrl)
        local _webhook = Webhooks?[resName]?[_action]
        if (_webhook) then return _webhook end

        return providedUrl -- Kept for older reasons
    end

    local bot = {
        username = "Zyke Resources' Logs",
        avatar = "https://cdn.discordapp.com/attachments/1048900415967744031/1117129086104514721/New_Logo.png",
        webhook = getWebhook(scriptName, action, webhook)
    }

    if (not bot.webhook or #bot.webhook <= 0) then return end

    local handlerMsg = ""
    if (handler == nil or handler == "server") then
        handlerMsg = "Server"
    else
        local isIdentifier = type(handler) == "string"
        if (not isIdentifier) then
            handler = Functions.GetIdentifier(handler)
        end

        local handlerData = handlers[handler]

        handlerMsg = handlerMsg .. (handlerData?.discord and ("<@%s>"):format(handlerData.discord) or "Missing Discord") .. " | "
        handlerMsg = handlerMsg .. (handlerData?.identifier and handlerData.identifier or "Missing Identifier") .. " | "
        handlerMsg = handlerMsg .. (handlerData?.firstname and handlerData.firstname or "Missing first name") .. " "
        handlerMsg = handlerMsg .. (handlerData?.lastname and handlerData.lastname or "Missing last name")
    end

    local basicInformationStr = ""
    basicInformationStr = basicInformationStr .. "Script: " .. scriptName .. "\n"
    basicInformationStr = basicInformationStr .. "Action: " .. action .. "\n"
    basicInformationStr = basicInformationStr .. "Handler: " .. handlerMsg

    local fields = {
        {
            ["name"] = "Basic Information",
            ["value"] = basicInformationStr
        },
        {
            ["name"] = "Message",
            ["value"] = message
        },
    }

    -- Append the raw data if it exists
    if (rawData) then
        fields[#fields+1] = {
            ["name"] = "Raw Data",
            ["value"] = "```" .. json.encode(rawData, {indent = false}) .. "```",
        }
    end

    local embeds = {
        {
            ["type"] = "rich",
            ["fields"] = fields,
            ["color"] = "3447003", -- https://gist.github.com/thomasbnt/b6f455e2c7d743b796917fa3c205f812
            ["footer"]=  {
                ["icon_url"] = "https://cdn.discordapp.com/attachments/1048900415967744031/1081687600080879647/toppng.com-browser-history-clock-icon-vector-white-541x541.png",
                ["text"] = "Sent: " .. os.date(),
            },
        }
    }

    local payload = {
        embeds = embeds,
        username = bot.username,
        avatar_url = bot.avatar
    }

    PerformHttpRequest(bot.webhook, function(err, text, headers)
        -- print(err, text, json.encode(headers))
        if (err ~= 204) then
            print(("Logging failed for webhook: %s"):format(bot.webhook))
            Functions.Debug(("Logging failed for webhook: %s"):format(bot.webhook))
        end
    end, "POST",json.encode(payload), {["Content-Type"] = "application/json"})
end

-- This is free to change, you can see all values used if you want to change it in any way
-- Keep in mind, we will not provide support for any changes made to the snippet below
local logQueue = {}
local inLogLoop = false
---@class LogData
---@field scriptName string? @Not originally provided, but gets added
---@field action string
---@field handler string
---@field message string
---@field rawData table?
---@field webhook string? @Support for old resources

---@param passed LogData
function Functions.Log(passed)
    if (type(passed) ~= "table") then error("You are attempting to log invalid data") return end -- Make sure the passed argument is a table to continue

    passed.scriptName = GetInvokingResource() -- Get the name of the resource that called the function

    logQueue[#logQueue+1] = passed

    if (inLogLoop) then return end

    inLogLoop = true
    CreateThread(function()
        while (#logQueue > 0) do
            local log = logQueue[1]

            Functions.Debug("Sending log: " .. log.action, Config.Debug)
            sendLog(log.scriptName, log.action, log.handler, log.message, log.rawData, log.webhook)
            table.remove(logQueue, 1)
            Wait(350) -- Prevents ratelimiting
        end

        inLogLoop = false
    end)
end

function Functions.HasItem(player, item, amount)
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    if (not player) then return false, Functions.Debug("Player not found (CRITICAL!)") end

    if (Framework == "QBCore") then
        local source = Functions.GetSource(player)
        local formatted = Functions.FormatItems(item, amount)

        if (Inventory == "ox_inventory") then
            for name, _amount in pairs(formatted) do
                local hasItem = QBCore.Functions.HasItem(source, name, _amount)

                if (hasItem == false) then return false end
            end

            return true
        else
            local hasItem = QBCore.Functions.HasItem(source, formatted)
            return hasItem
        end

        -- If your inventory doesn't support multiple items in a table, use the code below instead (Examples are c8re inventory)
        -- for name, _amount in pairs(formatted) do
        --     local hasItem = QBCore.Functions.HasItem(source, name, _amount)

        --     if (hasItem == false) then return false end
        -- end
        -- return true
    elseif (Framework == "ESX") then
        local formatted = Functions.FormatItems(item, amount)
        local hasItems = true

        for itemIdx, itemData in pairs(formatted) do
            local hasItem = player.getInventoryItem(itemData.name)

            -- DEV (Make sure this works since there is a weird error)
            if ((hasItem?.count or 0) < itemData.count) then
                hasItems = false
            end
        end

        return hasItems
    end
end

---@param disableBundling boolean? -- If set to true, it will not bundle item amounts with the same name (Read the formatting functions for full details)
function Functions.GetPlayerItems(player, disableBundling)
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    if (Framework == "QBCore") then
        local items = player.PlayerData.items

        return Functions.FormatItemsFetch(items, disableBundling)
    elseif (Framework == "ESX") then
        local items = player.inventory

        return Functions.FormatItemsFetch(items, disableBundling)
    end
end

---@param name string
---@param player string | number | table -- Will convert
---@param firstOnly boolean? -- Set to true to return the first item found, instead of an array containing all item tables that match the name
---@param disableBundling boolean? -- If set to true, it will not bundle item amounts with the same name (Read the formatting functions for full details)
---@param metadata table
---@return table | nil
function Functions.GetPlayerItemByName(player, name, firstOnly, disableBundling, metadata)
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    local playerItems = Functions.GetPlayerItems(player, disableBundling)
    local foundItems = {}

    for _, itemData in pairs(playerItems) do
        if (itemData.name == name) then
            if (metadata and type(metadata) == "table") then -- TODO: Add QB support
                for metaName, metaValue in pairs(metadata) do
                    if (not itemData?.metadata?[metaName] or itemData?.metadata?[metaName] ~= metaValue) then
                        goto endOfLoop
                    end
                end
            end

            if (firstOnly) then return itemData end

            foundItems[#foundItems+1] = itemData
        end

        ::endOfLoop::
    end

    return #foundItems > 0 and foundItems or nil
end

function Functions.RemoveItem(player, item, amount, metadata) -- TODO: Add qb-core metadata support
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    if (not player) then return false, Functions.Debug("Player not found (CRITICAL!)") end

    if (Framework == "QBCore") then
        local formatted = Functions.FormatItems(item, amount)

        for _item, _amount in pairs(formatted) do
            local isItemUnique = QBCore.Shared.Items[_item].unique
            local success = true

            if (isItemUnique) then
                for i = 1, _amount do
                    local _success = player.Functions.RemoveItem(_item, 1)
                    if (not _success) then success = false end
                end
            else
                local _success = player.Functions.RemoveItem(_item, _amount)
                if (not _success) then success = false end
            end

            if (not success) then
                error("CRITICAL ERROR! Attempted to remove items which could not be removed. Please contact the developer of the script you're using." .. " (" .. tostring(_item) .. ", " .. tostring(_amount) .. ")")
            end
        end

        return true
    elseif (Framework == "ESX") then
        local formatted = Functions.FormatItems(item, amount)

        for itemIdx, itemData in pairs(formatted) do
            player.removeInventoryItem(itemData.name, itemData.count, metadata)
        end

        return true
    end
end

---@param plyId integer
---@param item string
---@param amount integer
---@param slot integer
function Functions.RemoveFromSlot(plyId, item, amount, slot)
    if (Inventory == "ox_inventory") then
        exports["ox_inventory"]:RemoveItem(plyId, item, amount, nil, slot)

        return
    end

    local player = Functions.GetPlayer(plyId)
    if (not player) then return false, Functions.Debug("Player not found (CRITICAL!)") end

    if (Framework == "QBCore") then
        local inv = player.PlayerData.items

        for i = 1, #inv do
            if (inv[i].slot == slot) then
                inv[i].amount = inv[i].amount - amount
                if (inv[i].amount <= 0) then
                    inv[i] = nil
                end

                break
            end
        end

        player.Functions.SetPlayerData("items", inv)

        return
    end

    inventoryCompWarning()
end

function Functions.AddItem(player, item, amount, metadata)
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    if (not player) then return false, Functions.Debug("Player not found (CRITICAL!)") end

    if (Framework == "QBCore") then
        local formatted = Functions.FormatItems(item, amount)

        for _item, _amount in pairs(formatted) do
            player.Functions.AddItem(_item, _amount, nil, metadata)
        end

        return true
    elseif (Framework == "ESX") then
        local formatted = Functions.FormatItems(item, amount)

        for itemIdx, itemData in pairs(formatted) do
            player.addInventoryItem(itemData.name, itemData.count, metadata)
        end

        return true
    end
end

---@param plyId string | number | table -- Will convert
---@param slot integer
---@param metadata table
function Functions.SetItemMetadata(plyId, slot, metadata)
    if (type(plyId) ~= "number") then
        plyId = Functions.GetSource(plyId)
    end

    if (not plyId) then return false, Functions.Debug("Player not found (CRITICAL!)") end

    -- ox_inventory allows us to change one slot
    if (Inventory == "ox_inventory") then
        exports["ox_inventory"]:SetMetadata(plyId, slot, metadata)

        return
    end

    -- If we are not using ox_inventory, we will have to fetch the inventory, make the modifications ourselves and set the inventory
    if (Framework == "QBCore") then
        -- We'll have to grab the raw QBCore inventoy and modify it, to make sure all the data is correct
        local player = Functions.GetPlayer(plyId)
        if (not player) then error("Player not found (CRITICAL!)") return false end

        local inv = player.PlayerData.items

        for i = 1, #inv do
            if (inv[i].slot == slot) then
                inv[i].info = metadata
                break
            end
        end

        player.Functions.SetPlayerData("items", inv)
    elseif (Framework == "ESX") then
        -- Note that ESX does not offer such a feature by default
        -- If you are using ESX and any other inventory than ox_inventory, you will have to edit this yourself
        error("ESX does not support setting item metadata, please use ox_inventory or implement your own inventory system")
    end
end

function Functions.GetPlayersOnJob(job, onDuty)
    while (Framework == nil) do Wait(100) end

    if (Framework == "QBCore") then
        if (onDuty == true) then
            if (type(job) == "string") then
                return QBCore.Functions.GetPlayersOnDuty(job)
            elseif (type(job) == "table") then
                local players = {}

                for _, v in pairs(job) do
                    local jobPlayers = QBCore.Functions.GetPlayersOnDuty(v)

                    for _, v2 in pairs(jobPlayers) do
                        table.insert(players, v2)
                    end
                end

                return players
            end

            return {}
        end
    elseif (Framework == "ESX") then
        -- ESX doesn't have a default duty system, that's why we're not using it here
        -- If you do have it on your server, you can use the onDuty variable if it's needed in the script
        local players = {}

        if (type(job) == "string") then
            for k, v in pairs(ESX.GetPlayers()) do
                local xPlayer = ESX.GetPlayerFromId(v)

                if (xPlayer) then
                    if (xPlayer.job.name == job) then
                        table.insert(players, v)
                    end
                end
            end
        elseif (type(job) == "table") then
            for k, v in pairs(ESX.GetPlayers()) do
                local xPlayer = ESX.GetPlayerFromId(v)

                if (xPlayer) then
                    for _, v2 in pairs(job) do
                        if (xPlayer.job.name == v2) then
                            table.insert(players, v)
                        end
                    end
                end
            end
        end

        return players
    end
end

---@param gang string | table
---@return table
function Functions.GetPlayersOnGang(gang)
    while (Framework == nil) do Wait(100) end

    if (Framework == "QBCore") then
    elseif (Framework == "ESX") then
        if (GangScript == "zyke_gangphone") then
            local players = {}

            for _, plyId in pairs(GetPlayers()) do
                local plyGang = exports["zyke_gangphone"]:GetPlayerGangId(plyId)

                if (plyGang) then
                    if (type(gang) == "string") then
                        if (plyGang == gang) then
                            players[#players+1] = plyId
                        end
                    elseif (type(gang) == "table") then
                        for _, _gang in pairs(gang) do
                            if (plyGang == _gang) then
                                players[#players+1] = plyId
                            end
                        end
                    end
                end
            end

            return players
        end
    end

    return {}
end

function Functions.EnoughWorkers(job, required)
    local players = Functions.GetPlayersOnJob(job, true)

    if (players ~= nil) then
        if (#players >= required) then
            return true
        else
            return false
        end
    else
        return false
    end
end

function Functions.CreateUseableItem(item, func)
    CreateThread(function()
        while (Framework == nil) do Wait(100) end

        if (Framework == "QBCore") then
            QBCore.Functions.CreateUseableItem(item, function(source, itemData)
                func(source, Functions.FormatItemsFetch(itemData))
            end)
        elseif (Framework == "ESX") then
            ESX.RegisterUsableItem(item, function(source, itemName, itemData)
                func(source, Functions.FormatItemsFetch(itemData))
            end)
        end
    end)
end

function Functions.CreateCallback(name, passed)
    CreateThread(function()
        while (Framework == nil) do Wait(100) end

        if (Framework == "QBCore") then
            QBCore.Functions.CreateCallback(name, passed)
        elseif (Framework == "ESX") then
            ESX.RegisterServerCallback(name, passed)
        end
    end)
end

function Functions.GetPlayer(source)
    local _source = tonumber(source)
    if (_source == nil) then _source = source end

    if (type(_source) == "string") then
        return Functions.GetPlayerFromIdentifier(_source)
    end

    if (Framework == "QBCore") then
        return QBCore.Functions.GetPlayer(_source)
    elseif (Framework == "ESX") then
        return ESX.GetPlayerFromId(_source) -- Error
    end
end

-- Does not accept the identifier to be the player table for conversion
function Functions.GetPlayerDetails(identifier)
    if (identifier == nil) then return nil end

    if (type(identifier) == "table") then
        local identifiers = {}

        for idx, _identifier in pairs(identifier) do
            identifiers[idx] = Functions.GetPlayerDetails(_identifier)
        end

        return identifiers
    end

    if (tonumber(identifier) ~= nil) then -- Is a source, but set as string
        identifier = Functions.GetIdentifier(tonumber(identifier))
    elseif (type(identifier) ~= "string") then
        identifier = Functions.GetIdentifier(identifier)
    end

    local online = true
    if (Framework == "QBCore") then
        local character = QBCore.Functions.GetPlayerByCitizenId(identifier)
        if (not character) then
            character = QBCore.Functions.GetOfflinePlayerByCitizenId(identifier)
            online = false
        end

        return Functions.FormatCharacterDetails(character, online)
    elseif (Framework == "ESX") then
        local character = ESX.GetPlayerFromIdentifier(identifier)

        if (not character) then
            character = Functions.GetOfflinePlayer(identifier)
            online = false
        end

        return Functions.FormatCharacterDetails(character, online)
    end
end

function Functions.GetOfflinePlayer(identifier)
    if (identifier == nil) then return nil end

    if (type(identifier) ~= "string") then
        identifier = Functions.GetIdentifier(identifier)
    end

    if (Framework == "QBCore") then
        return QBCore.Functions.GetOfflinePlayerByCitizenId(identifier)
    elseif (Framework == "ESX") then
        local p = promise.new()
        MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {["@identifier"] = identifier}, function(result)
            local character = result[1]
            if (not character) then p:resolve(nil) return end

            character.accounts = json.decode(character.accounts)
            character.inventory = json.decode(character.inventory)
            character.loadout = json.decode(character.loadout)
            character.position = json.decode(character.position)
            character.skin = json.decode(character.skin)
            character.status = json.decode(character.status)
            character.metadata = json.decode(character.metadata or {})

            p:resolve(character)
        end)

        return Citizen.Await(p)
    end
end

-- Has to be the static identifider (citizenid/identifier) to verify
-- @returns
-- boolean, if identifier is valid
-- boolean, if player is online
function Functions.IsIdentifierValid(identifier)
    local player = Functions.GetPlayer(identifier)
    if (player) then return true, true end

    local player = Functions.GetOfflinePlayer(identifier)
    if (player) then return true, false end

    return false, false
end

function Functions.GetPlayerFromIdentifier(identifier)
    if (Framework == "QBCore") then
        return QBCore.Functions.GetPlayerByCitizenId(identifier)
    elseif (Framework == "ESX") then
        return ESX.GetPlayerFromIdentifier(identifier)
    end
end

function Functions.GetSourceFromIdentifier(identifier)
    local player = Functions.GetPlayerFromIdentifier(identifier)
    if (not player) then return nil end

    return Functions.GetSource(player)
end

function Functions.GetIdentifier(player)
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    if (Framework == "QBCore") then
        return player?.PlayerData?.citizenid
    elseif (Framework == "ESX") then
        return player?.identifier
    end
end

function Functions.AddMoney(player, moneyType, amount, details)
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    if (Framework == "QBCore") then
        player.Functions.AddMoney(moneyType, amount, details)
    elseif (Framework == "ESX") then
        moneyType = moneyType == "cash" and "money" or moneyType -- ESX uses "money" instead of "cash", so we're converting it here
        moneyType = moneyType == "dirty_cash" and "black_money" or moneyType -- ESX uses "black_money" instead of "dirty_cash", so we're converting it here
        player.addAccountMoney(moneyType, amount, details)
    end
end

function Functions.GetMoney(player, moneyType)
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    moneyType = moneyType == nil and "cash" or moneyType -- If no moneyType is given, we're using "cash" as default

    if (Framework == "QBCore") then
        return player.PlayerData.money[moneyType]
    elseif (Framework == "ESX") then
        moneyType = moneyType == "cash" and "money" or moneyType -- ESX uses "money" instead of "cash", so we're converting it here
        moneyType = moneyType == "dirty_cash" and "black_money" or moneyType -- ESX uses "black_money" instead of "dirty_cash", so we're converting it here
        return player.getAccount(moneyType).money -- Not tested (Not used for any releases)
    end
end

function Functions.RemoveMoney(player, moneyType, amount, details)
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    if (Framework == "QBCore") then
        player.Functions.RemoveMoney(moneyType, amount, details)
    elseif (Framework == "ESX") then
        moneyType = moneyType == "cash" and "money" or moneyType -- ESX uses "money" instead of "cash", so we're converting it here
        moneyType = moneyType == "dirty_cash" and "black_money" or moneyType -- ESX uses "black_money" instead of "dirty_cash", so we're converting it here
        player.removeAccountMoney(moneyType, amount, details) -- Not tested (Not used for any releases)
    end
end

---@param player table | string | number
---@return number | nil, string?
function Functions.GetSource(player)
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    if (not player) then
        return nil, "playerOffline"
    end

    if (Framework == "QBCore") then
        return player.PlayerData.source
    elseif (Framework == "ESX") then
        return player.source
    end
end

function Functions.HasPermission(source, permission)
    if (type(source) ~= "number") then
        source = Functions.GetSource(source)
    end

    if (Framework == "QBCore") then
        return QBCore.Functions.HasPermission(source, permission)
    elseif (Framework == "ESX") then
        local plyPermission = ESX.GetPlayerFromId(source).getGroup()
        local hasPermission = plyPermission == "superadmin" or plyPermission == permission

        return hasPermission
    end
end

function Functions.GetInventory(invId)
    if (Framework == "QBCore") then
        -- For some reason you can only retrieve this by a client callback, so I copied the code from the inventory
        -- If anyone knows of a better way, please feel free to make a pull request or let me know
        local items = {}
        local result = MySQL.scalar.await('SELECT items FROM stashitems WHERE stash = ?', {invId})
        if not result then return items end

        local stashItems = json.decode(result)
        if not stashItems then return items end

        for _, item in pairs(stashItems) do
            local itemInfo = QBCore.Shared.Items[item.name:lower()]
            if itemInfo then
                items[item.slot] = {
                    name = itemInfo["name"],
                    amount = tonumber(item.amount),
                    info = item.info or "",
                    label = itemInfo["label"],
                    description = itemInfo["description"] or "",
                    weight = itemInfo["weight"],
                    type = itemInfo["type"],
                    unique = itemInfo["unique"],
                    useable = itemInfo["useable"],
                    image = itemInfo["image"],
                    slot = item.slot,
                }
            end
        end

        return items
    elseif (Framework == "ESX") then
        return ESX.GetInventory(invId) -- Not tested (Not in use for any active releases yet)
    end
end

function Functions.OpenInventory(invId, type)
    type = type or "stash"
    if (Framework == "QBCore") then
        TriggerEvent("inventory:server:OpenInventory", type, invId)
    elseif (Framework == "ESX") then
        -- return ESX.GetInventory(invId) -- Not tested (Not in use for any active releases yet)
    end
end

function Functions.GetPlayers()
    if (Framework == "QBCore") then
        return QBCore.Functions.GetPlayers()
    elseif (Framework == "ESX") then
        return ESX.GetPlayers()
    end
end

---@param pos vector3
---@return number, number
function Functions.GetClosestPlayerToPos(pos)
    local players = Functions.GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1

    for _, plyId in pairs(players) do
        local targetPed = GetPlayerPed(plyId)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(vector3(pos.x, pos.y, pos.z) - targetCoords)

        if (closestDistance == -1 or closestDistance > distance) then
            closestPlayer = plyId
            closestDistance = distance
        end
    end

    return closestPlayer, closestDistance
end

function Functions.Notify(source, msg, type)
    TriggerClientEvent("zyke_lib:Notify", source, msg, type)
end

function Functions.DBFetch(query, params)
    if (not query) then Functions.Debug("No query passed (CRITICAL!)", Config.Debug) return end

    local p = promise.new()

    MySQL.Async.fetchAll(query, params or {}, function(result)
        p:resolve(result)
    end)

    return Citizen.Await(p)
end

function Functions.DBExecute(query, params, async)
    if (not query) then Functions.Debug("No query passed (CRITICAL!)", Config.Debug) return end

    if (async == true) then
        MySQL.Async.execute(query, params or {})
        return
    end

    local p = promise.new()

    MySQL.Async.execute(query, params or {}, function(result)
        p:resolve(result)
    end)

    return Citizen.Await(p)
end

-- Requires a static identifier (citizenid/identifier), otherwise results will become unpredictible if the player is offline
function Functions.GetAccountIdentifier(identifier)
    if (type(identifier) ~= "string") then
        identifier = Functions.GetIdentifier(identifier)
    end

    if (Framework == "QBCore") then
        local character = Functions.GetPlayer(identifier) or Functions.GetOfflinePlayer(identifier)

        return character?.PlayerData?.license or nil
    elseif (Framework == "ESX") then
        local character = Functions.GetPlayer(identifier) or Functions.GetOfflinePlayer(identifier)
        if (not character) then return nil end

        local trimmed = character.license:gsub("license:", "")

        return trimmed
    end

    return nil
end

local function insertIntoHandlers(player)
    local identifier = Functions.GetIdentifier(player)
    local source = Functions.GetSource(identifier)
    local character = Functions.GetPlayerDetails(identifier)

    if (not source) then Functions.Debug("Source not found (CRITICAL!)", Config.Debug) return end

    handlers[identifier] = {
        firstname = character?.firstname,
        lastname = character?.lastname,
        identifier = identifier,
        source = source,
    }

    for _, id in pairs(GetPlayerIdentifiers(source)) do
        local colon = id:find(":")
        if (colon) then
            local key = id:sub(1, colon - 1)
            local value = id:sub(colon + 1)

            handlers[identifier][key] = value
        end
    end
end

AddEventHandler("zyke_lib:PlayerJoined", function(player)
    insertIntoHandlers(player)
end)

AddEventHandler("onResourceStart", function(resource)
    if (GetCurrentResourceName() ~= resource) then return end

    while (not Functions.HasLoadedFramework()) do Wait(1) end

    for _, player in pairs(Functions.GetPlayers()) do
        insertIntoHandlers(Functions.GetIdentifier(player))
    end
end)

---@param identifier string | number @Use player id if you do not have the player identifier, requires more performance
---@param desiredIdentifiers string | table<string>? @String or list of strings of identifiers you want
---@param labelForNonExisting string | nil @If the identifier does not exist, replace it with this label
---@return string | table | nil
function Functions.GetAccountIdentifiers(identifier, desiredIdentifiers, labelForNonExisting)
    if (not identifier) then return nil end

    local values = {}
    if (type(identifier) == "string") then
        values = handlers[identifier]
    elseif (type(identifier) == "number") then
        for _, id in pairs(GetPlayerIdentifiers(identifier)) do
            local colon = id:find(":")
            if (colon) then
                local key = id:sub(1, colon - 1)
                local value = id:sub(colon + 1)

                values[key] = value
            end
        end
    end

    if (not values) then return nil end

    if (type(desiredIdentifiers) == "string") then
        local value = values[desiredIdentifiers]

        return value or labelForNonExisting
    elseif (type(desiredIdentifiers) == "table") then
        local identifiers = {}

        for _, desiredIdentifier in pairs(desiredIdentifiers) do
            local value = values[desiredIdentifier]

            identifiers[desiredIdentifier] = value or labelForNonExisting
        end

        return identifiers
    end

    return nil
end

math.randomseed(os.time())
-- Has to have a character in the first position, otherwise there will be database errors as it removes the first sequence of numbers for some reason
-- Unsure as to what causes this issue, we will just ensure that a character is in the first position as it doesn't matter
---@param length number
---@return string
function Functions.CreateUniqueId(length)
    length = (length or 20) - 1 -- Max characters

    local id = string.char(math.random(65, 90))
    for _ = 1, length do
        local randNum = math.random(36)
        local charCode = randNum <= 10 and randNum + 47 or randNum + 54

        id = id .. string.char(charCode)
    end

    return id
end

-- If your inventory requires you to register the stash, it is done in here
---@param id string
function Functions.RegisterStash(id, label, slots, weight)
    if (Inventory == "ox_inventory") then
        local stash = Functions.GetStash(id)

        if (not stash) then
            exports["ox_inventory"]:RegisterStash(id, label, slots, weight)
        end
    end
end

-- Untested
---@param id string
function Functions.OpenStash(id, plyId)
    if (Inventory == "ox_inventory") then
        exports["ox_inventory"]:forceOpenInventory(plyId, id)
    end
end

---@param id string
function Functions.GetStash(id)
    if (Inventory == "ox_inventory") then
        return exports["ox_inventory"]:GetInventory(id)
    end

    return nil
end

---@param player string | number | table -- Will convert
---@return table | nil
function Functions.GetJob(player)
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    if (Framework == "QBCore") then
        local details = player.PlayerData.job
        if (not details) then return nil end

        return Functions.FormatJob(details)
    elseif (Framework == "ESX") then
        local details = player.job
        if (not details) then return nil end

        return Functions.FormatJob(details)
    end
end

---@param job string
---@param amount number
---@return boolean @ Success
function Functions.PaySociety(job, amount)
    if (Framework == "QBCore") then
        -- exports['qb-management']:AddMoney(job, amount) -- Old export
        exports["qb-banking"]:AddMoney(job, amount)

        return true -- Always returns true, if the money is not added it will create an account to add the money to, does not return if anything fails
    elseif (Framework == "ESX") then
        TriggerEvent("esx_addonaccount:getSharedAccount", job, function(account)
            if (account) then
                account.addMoney(amount)
                return true
            end

            return false
        end)
    end

    return false
end

---@param player string | number | table -- Will convert
function Functions.GetGang(player)
    player = Functions.GetPlayer(player)

    if (Framework == "QBCore") then
        local details = player.PlayerData.gang
        if (not details) then return nil end

        return Functions.FormatGang(details)
    elseif (Framework == "ESX") then
        if (GangScript == "zyke_gangphone") then
            local plySource = Functions.GetSource(player)
            local plyGangDetails = exports["zyke_gangphone"]:GetPlayerGangDetails(plySource)

            return Functions.FormatGang(plyGangDetails)
        end

        return nil
    end
end

---@param job string
---@param onDuty boolean
---@return table -- Array
function Functions.GetDetailedPlayersOnJob(job, onDuty)
    local playersOnJob = Functions.GetPlayersOnJob(job, onDuty)
    local formattedPlayers = {}

    for _, plyId in pairs(playersOnJob) do
        local format = {}
        local plyJob = Functions.GetJob(plyId)

        format = plyJob or {}
        format.identifier = Functions.GetIdentifier(plyId)
        format.source = plyId

        table.insert(formattedPlayers, format)
    end

    return formattedPlayers
end

---@param gang string
---@return table -- Array
function Functions.GetDetailedPlayersOnGang(gang)
    local playersOnGang = Functions.GetPlayersOnGang(gang)
    local formattedPlayers = {}

    for _, plyId in pairs(playersOnGang) do
        local format = {}
        local plyGang = Functions.GetGang(plyId)

        format = plyGang or {}
        format.identifier = Functions.GetIdentifier(plyId)
        format.source = plyId

        formattedPlayers[#formattedPlayers+1] = format
    end

    return formattedPlayers
end

---@param profession string -- Name of profession
---@param professionType string -- "job" or "gang"
---@param onDuty boolean
---@return table -- Array of ids
function Functions.GetBossesForProfession(profession, professionType, onDuty)
    if (onDuty == nil) then onDuty = true end

    local bosses = {}

    local players = professionType == "job" and Functions.GetDetailedPlayersOnJob(profession, onDuty) or Functions.GetDetailedPlayersOnGang(profession)
    if (not players) then return bosses end

    local bossRanks = Functions.GetBossRanks(profession, professionType)
    if (not bossRanks) then return bosses end

    for _, player in pairs(players) do
        local rank = professionType == "job" and player.grade.name or player.grade.name
        if (bossRanks[rank]) then
            table.insert(bosses, player.source)
        end
    end

    return bosses
end

--[[
    driver (QB & ESX)
]]
-- Only intended for online-players
---@param identifier string
---@param licenseType string
---@return boolean
function Functions.HasLicense(identifier, licenseType)
    local translations = {
        ["QBCore"] = {
            ["car"] = "driver"
        },
        ["ESX"] = {
            ["car"] = "drive"
        }
    }

    licenseType = translations[Framework][licenseType]

    if (Framework == "QBCore") then
        local player = Functions.GetPlayer(identifier)
        if (not player) then return false end

        local licenses = player.PlayerData.metadata["licences"]
        if (not licenses) then return false end

        return licenses[licenseType] or false
    elseif (Framework == "ESX") then
        local source = Functions.GetSource(identifier)
        if (not source) then return false end

        local p = promise.new()
        TriggerEvent('esx_license:getLicenses', source, function(licenses)
            for _, license in pairs(licenses) do
                if (license.type == licenseType) then
                    p:resolve(true)
                end
            end

            p:resolve(false)
		end)

        return Citizen.Await(p)
    end

    return false
end

local function syncSessions()
    GlobalState.sessions = Sessions
end

---@param type string @ "players" or "entities"
---@param playerId number
---@param sendToClient boolean?
---@param setSession boolean?
local function clearFromSession(type, playerId, sendToClient, setSession)
    for sessionId, sessionData in pairs(Sessions[type]) do
        for idx, session in pairs(sessionData) do
            if (session.playerId == playerId) then
                table.remove(Sessions[type][sessionId], idx)
                Functions.Debug("Removed from session: " .. type .. " | " .. playerId, Config.Debug)

                if (setSession) then
                    if (type == "players") then
                        ---@diagnostic disable-next-line: param-type-mismatch
                        SetPlayerRoutingBucket(playerId, 0)
                    elseif (type == "entities") then
                        SetEntityRoutingBucket(playerId, 0)
                    end
                end

                Player(playerId).state:set("session", 0, true)
                syncSessions()

                break
            end
        end
    end
end

---@param type string @ "players" or "entities"
---@param playerId number
---@param sessionId number
local function insertIntoSession(type, playerId, sessionId)
    if (not Sessions[type][sessionId]) then Sessions[type][sessionId] = {} end

    clearFromSession(type, playerId)

    table.insert(Sessions[type][sessionId], {
        playerId = playerId,
        type = type,
        set = os.time()
    })

    if (type == "players") then
        ---@diagnostic disable-next-line: param-type-mismatch
        SetPlayerRoutingBucket(playerId, sessionId)
        Player(playerId).state:set("session", sessionId, true)
    elseif (type == "entities") then
        SetEntityRoutingBucket(playerId, sessionId)
    end

    syncSessions()
    Functions.Debug("Inserted into session: " .. type .. " | " .. playerId .. " | " .. sessionId, Config.Debug)
end

-- TODO: Needs to be synced with netId, when fetching return both handler and netId
function Functions.SetEntitySession(entityId, sessionId)
    if (not (entityId or sessionId)) then Functions.Debug("No entityId or sessionId passed (CRITICAL!)", Config.Debug) return end

    insertIntoSession("entities", entityId, sessionId)
end

function Functions.SetPlayerSession(playerId, sessionId)
    if (not (playerId or sessionId)) then Functions.Debug("No playerId or sessionId passed (CRITICAL!)", Config.Debug) return end

    insertIntoSession("players", playerId, sessionId)
end

function Functions.ClearFromSessions(playerId, type)
    clearFromSession(type, playerId, true, true)
end

---@param sessionId string
---@param sessionType string @ "players" or "entities" or "combined"
function Functions.GetSession(sessionId, sessionType)
    local session = {}

    if (sessionType == "combined") then
        for _, player in pairs(Sessions.players[sessionId] or {}) do
            table.insert(session, player)
        end

        for _, entity in pairs(Sessions.entities[sessionId] or {}) do
            table.insert(session, entity)
        end
    elseif (sessionType == "players") then
        session = Sessions.players[sessionId] or {}
    elseif (sessionType == "entities") then
        session = Sessions.entities[sessionId] or {}
    end

    return session
end

function Functions.GetPlayerSessionId(playerId)
    if (not playerId) then Functions.Debug("No playerId passed (CRITICAL!)", Config.Debug) return end

    for sessionId, sessionData in pairs(Sessions.players) do
        for _, session in pairs(sessionData) do
            if (session.playerId == playerId) then
                return sessionId
            end
        end
    end

    return nil
end

CreateThread(function()
    Wait(1000)

    print("^4Thank you for choosing Zyke Resources!\nFor all enquiries, please visit our Discord.\n^3> discord.zykeresources.com / .gg/UaXtUFRr66^0")
end)