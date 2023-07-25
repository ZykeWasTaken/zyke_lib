-- This is free to change, you can see all values used if you want to change it in any way
-- Keep in mind, we will not provide support for any changes made to the snippet below
local logQueue = {}
local inLoop = false
local handlers = {} -- Caches handler data in order to prevent constant looping and easy access, could not find any way to natively do this in QBCore so I made my own solution
function Functions.Log(passed)
    if (type(passed) ~= "table") then return end -- Make sure the passed argument is a table to continue
    if (passed.logsEnabled == false) or (passed.logsEnabled == nil) then return end -- Make sure logs are enabled in that resource to continue

    passed.scriptName = GetInvokingResource() -- Get the name of the resource that called the function
    table.insert(logQueue, passed)
    CreateThread(function()
        SendLog()
    end)
end

-- Send queued logs
function SendLog()
    if (inLoop) then return end
    local function send(passed)
        -- Bot
        local username = "Zyke Resources' Logs"
        local avatarUrl = "https://cdn.discordapp.com/attachments/1048900415967744031/1117129086104514721/New_Logo.png"
        local webhook = passed.webhook or "" -- Insert a fallback webhook here, meaning if the resource doesn't have a webhook set, it will use this one instead

        -- Message
        local scriptName = passed.scriptName or "Unknown Script"
        local message = passed.message or "Empty Message"
        local action = passed.action or "Unknown Action"
        local handler = handlers[passed?.handler] or handlers[Functions.GetIdentifier(passed?.handler)] or "server"
        local handlerMsg = "None"

        if (handler ~= "server") then
            handlerMsg = (("<@" .. handler?.discord .. ">") or "unknown") .. " | " .. (handler?.identifier or "unknown") .. " | " .. (handler?.firstname or "unknown") .. " " .. (handler?.lastname or "unknown")
        else
            handlerMsg = "Server"
        end

        -- local getFileName = function()
        --     local uniqueNumber = tostring(math.random(100000000, 999999999))
        --     local path = "/server/logs/" .. scriptName .. "/" .. action .. "/"
        --     local name = uniqueNumber .. ".json"

        --     return path, name
        -- end

        -- local filePath, fileName = getFileName()

        local basicInformationStr = ""
        basicInformationStr = basicInformationStr .. "Script: " .. scriptName .. "\n"
        basicInformationStr = basicInformationStr .. "Action: " .. action .. "\n"
        basicInformationStr = basicInformationStr .. "Handler: " .. handlerMsg

        -- rawData additions
        local rawData = passed.rawData
        local encodedRawData = json.encode(rawData, {indent = false}) -- In large logs you may experience up to 2.5x more characters used if you indent, hence why it's disabled

        if (#encodedRawData > 1000) then
            encodedRawData = json.encode({
                ["error"] = "Log too large, will hit the character limit.",
                ["logSize"] = #encodedRawData,
            }, {indent = false})
        end

        local field1 = {
            ["name"] = "Basic Information",
            ["value"] = basicInformationStr,
        }

        local field2 = {
            ["name"] = "Message",
            ["value"] = message,
        }

        local field3 = {
            ["name"] = "Raw Data",
            ["value"] = "```" .. encodedRawData .. "```",
        }

        local embeds = {
            {
                ["type"] = "rich",
                ["fields"] = {field1, field2, field3},
                ["color"] = "3447003", -- https://gist.github.com/thomasbnt/b6f455e2c7d743b796917fa3c205f812
                ["footer"]=  {
                    ["icon_url"] = "https://cdn.discordapp.com/attachments/1048900415967744031/1081687600080879647/toppng.com-browser-history-clock-icon-vector-white-541x541.png",
                    ["text"] = "Sent: " .. os.date(),
                },
            }
        }

        local payload = {
            embeds = embeds,
            username = username,
            avatar_url = avatarUrl,
        }

        -- if (Config.ExtensiveLogs == true) then
        --     CreateExtensiveLog(filePath, fileName, rawData)
        -- end

        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
    end

    inLoop = true
    while (#logQueue > 0) do
        local log = logQueue[1]

        Functions.Debug("Sending log: " .. log.action, Config.Debug)
        send(log)
        table.remove(logQueue, 1)
        Wait(350) -- Prevents ratelimiting
    end
    inLoop = false
end

-- function CreateExtensiveLog(filePath, fileName, data)
--     local location = string.gsub(GetResourcePath(GetCurrentResourceName()), "^(.+\\)[^\\]+$", "%1") .. filePath

--     os.execute("mkdir " .. location:gsub("/", "\\"))
--     local file = io.open(location .. fileName, "w")
--     -- if (not file) then return false end
--     file:write(json.encode(data, {indent = true}))
--     file:close()
-- end

function Functions.HasItem(player, item, amount)
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    if (not player) then return false, Functions.Debug("Player not found (CRITICAL!)") end

    if (Framework == "QBCore") then
        local source = Functions.GetSource(player)
        local formatted = Functions.FormatItems(item, amount)

        local hasItem = QBCore.Functions.HasItem(source, formatted)
        return hasItem

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

-- Not used
function Functions.GetPlayerItemByName(player, item)
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    if (Framework == "QBCore") then
        return player.Functions.GetItemByName(item)
    elseif (Framework == "ESX") then
        return player.getInventoryItem(item)
    end
end

function Functions.RemoveItem(player, item, amount)
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    if (not player) then return false, Functions.Debug("Player not found (CRITICAL!)") end

    if (Framework == "QBCore") then
        local formatted = Functions.FormatItems(item, amount)

        for _item, _amount in pairs(formatted) do
            player.Functions.RemoveItem(_item, _amount)
        end

        return true
    elseif (Framework == "ESX") then
        local formatted = Functions.FormatItems(item, amount)

        for itemIdx, itemData in pairs(formatted) do
            player.removeInventoryItem(itemData.name, itemData.count)
        end

        return true
    end
end

function Functions.AddItem(player, item, amount)
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    if (not player) then return false, Functions.Debug("Player not found (CRITICAL!)") end

    if (Framework == "QBCore") then
        local formatted = Functions.FormatItems(item, amount)

        for _item, _amount in pairs(formatted) do
            player.Functions.AddItem(_item, _amount)
        end

        return true
    elseif (Framework == "ESX") then
        local formatted = Functions.FormatItems(item, amount)

        for itemIdx, itemData in pairs(formatted) do
            player.addInventoryItem(itemData.name, itemData.count)
        end

        return true
    end
end

function Functions.GetPlayersOnJob(job, onDuty)
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
    elseif (Framework == "ESX") then -- Untested
        -- ESX doesn't have a default duty system, that's why we're not using it here
        -- If you do have it on your server, you can use the onDuty variable if it's needed in the script
        local players = {}

        if (type(job) == "string") then
            for k, v in pairs(ESX.GetPlayers()) do
                local xPlayer = ESX.GetPlayerFromId(v)

                if (xPlayer.job.name == job) then
                    table.insert(players, v)
                end
            end
        elseif (type(job) == "table") then
            for k, v in pairs(ESX.GetPlayers()) do
                local xPlayer = ESX.GetPlayerFromId(v)

                for _, v2 in pairs(job) do
                    if (xPlayer.job.name == v2) then
                        table.insert(players, v)
                    end
                end
            end
        end

        return players
    end
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

function Functions.CreateUseableItem(item, passed)
    if (Framework == "QBCore") then
        QBCore.Functions.CreateUseableItem(item, passed)
    elseif (Framework == "ESX") then
        ESX.RegisterUsableItem(item, passed)
    end
end

function Functions.CreateCallback(name, passed)
    if (Framework == "QBCore") then
        QBCore.Functions.CreateCallback(name, passed)
    elseif (Framework == "ESX") then
        ESX.RegisterServerCallback(name, passed)
    end
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
    if (type(identifier) ~= "string") then
        identifier = Functions.GetIdentifier(identifier)
    end

    if (Framework == "QBCore") then
        return QBCore.Functions.GetOfflinePlayerByCitizenId(identifier)
    elseif (Framework == "ESX") then
        local p = promise.new()
        MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {["@identifier"] = identifier}, function(result)
            p:resolve(result[1])
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
        return IsPlayerAceAllowed(source, permission)
    end
end

-- Not tested and not active for any release yet, was temporarily tested for QB
function Functions.GetPlayerInventory(player)
    if (type(player) ~= "table") then
        player = Functions.GetPlayer(player)
    end

    if (Framework == "QBCore") then
        return player.PlayerData.items
    elseif (Framework == "ESX") then
        return player.inventory
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

-- vec3
function Functions.GetClosestPlayerToPos(pos)
    local players = Functions.GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1

    for _, plyId in pairs(players) do
        local targetPed = GetPlayerPed(plyId)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(pos - targetCoords)

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

function Functions.DBExecute(query, params)
    if (not query) then Functions.Debug("No query passed (CRITICAL!)", Config.Debug) return end

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
        -- Untested, and has to be formatted
    end

    return nil
end

local function insertIntoHandlers(player)
    local identifier = Functions.GetIdentifier(player)
    local source, reason = Functions.GetSource(identifier)
    local character = Functions.GetPlayerDetails(identifier)
    local discord = "NOT FOUND"

    if (not source) then Functions.Debug("Source not found (CRITICAL!)", Config.Debug) return end

    for _, id in pairs(GetPlayerIdentifiers(source)) do
        if string.find(id, "discord:") then
            discord = id:gsub("discord:", "")
            break
        end
    end

    handlers[identifier] = {
        firstname = character?.firstname,
        lastname = character?.lastname,
        identifier = identifier,
        source = source,
        discord = discord
    }
end

AddEventHandler("zyke_lib:PlayerJoined", function(player)
    insertIntoHandlers(player)
end)

AddEventHandler("onResourceStart", function(resource)
    if (GetCurrentResourceName() ~= resource) then return end

    Wait(100) -- Initial wait to ensure that the framework is fetched first

    for _, player in pairs(Functions.GetPlayers()) do
        insertIntoHandlers(Functions.GetIdentifier(player))
    end
end)

function Functions.CreateUniqueId(length)
    length = length or 20 -- Max characters

    math.randomseed(os.time())

    local id = ""
    for i = 1, length do
        local randNum = math.random(36)
        local charCode = randNum <= 10 and randNum + 47 or randNum + 54
        id = id .. string.char(charCode)
    end

    return id
end

CreateThread(function()
    Wait(1000)
    print([[
^4Thanks for choosing

███████╗██╗░░░██╗██╗░░██╗███████╗
╚════██║╚██╗░██╔╝██║░██╔╝██╔════╝
░░███╔═╝░╚████╔╝░█████═╝░█████╗░░
██╔══╝░░░░╚██╔╝░░██╔═██╗░██╔══╝░░
███████╗░░░██║░░░██║░╚██╗███████╗
╚══════╝░░░╚═╝░░░╚═╝░░╚═╝╚══════╝
██████╗░███████╗░██████╗░█████╗░██╗░░░██╗██████╗░░█████╗░███████╗░██████╗
██╔══██╗██╔════╝██╔════╝██╔══██╗██║░░░██║██╔══██╗██╔══██╗██╔════╝██╔════╝
██████╔╝█████╗░░╚█████╗░██║░░██║██║░░░██║██████╔╝██║░░╚═╝█████╗░░╚█████╗░
██╔══██╗██╔══╝░░░╚═══██╗██║░░██║██║░░░██║██╔══██╗██║░░██╗██╔══╝░░░╚═══██╗
██║░░██║███████╗██████╔╝╚█████╔╝╚██████╔╝██║░░██║╚█████╔╝███████╗██████╔╝
╚═╝░░╚═╝╚══════╝╚═════╝░░╚════╝░░╚═════╝░╚═╝░░╚═╝░╚════╝░╚══════╝╚═════╝░^0
]])
end)

function Fetch()
    return Functions, Tools
end

exports("Fetch", Fetch)