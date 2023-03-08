function Fetch()
    return Functions
end

-- This is free to change, you can see all values used if you want to change it in any way
-- Keep in mind, we will not provide support for any changes made to the snippet below
function Functions.Log(passed)
    if (type(passed) ~= "table") then return end -- Make sure the passed argument is a table to continue
    if (passed.logsEnabled == false) or (passed.logsEnabled == nil) then return end -- Make sure logs are enabled in that resource to continue

    -- Bot
    local username = "Zyke Resources' Logs"
    local avatarUrl = "https://cdn.discordapp.com/attachments/1048900415967744031/1081685770898784506/zyke.jpg"
    local webhook = passed.webhook or "" -- Insert a fallback webhook here, meaning if the resource doesn't have a webhook set, it will use this one instead

    -- Message
    local scriptName = passed.scriptName or "Unknown Script"
    local identifier = passed.identifier or "Unknown Identifier"
    local message = passed.message or "Empty Message"
    local action = passed.action or "Unknown Action"

    local field1 = {
        ["name"] = "Basic Information",
        ["value"] = "Script: " .. scriptName .. "\nIdentifier: " .. identifier .. "\nAction: " .. action,
    }

    local field2 = {
        ["name"] = "Message",
        ["value"] = message,
    }

    local field3 = passed.rawData and {
        ["name"] = "Raw Data",
        ["value"] = json.encode(passed.rawData, {indent = true}),
    } or nil

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

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
end

-- Framework is set in config.lua file
-- If you're running a default framework, you probably won't need to change this
-- However, if you are running some modified files you might want to tinker with this in order to make it work
-- If you can't get it to work for your specific server, our Discord is open for support: https://discord.gg/zykeresources
function Functions.HasItem(identifier, passed)
    if (passed.item == nil) or (passed.amount == nil) then return false end -- Make sure the passed arguments are valid to continue

    if (Config.Framework == "QBCore") then
        local Player = QBCore.Functions.GetPlayer(identifier)
        local item = Player.Functions.GetItemByName(passed.item)

        if ((item?.amount or 0) >= passed.amount) then
            return true
        else
            return false
        end
    elseif (Config.Framework == "ESX") then
        local xPlayer = ESX.GetPlayerFromId(identifier)
        local item = xPlayer.getInventoryItem(passed.item)

        if ((item?.count or 0) >= passed.amount) then
            return true
        else
            return false
        end
    end
end

function Functions.AddItem(identifier, passed)
    if (passed.item == nil) then return false end

    local amount = passed.amount or 1

    if (Config.Framework == "QBCore") then
        local Player = QBCore.Functions.GetPlayer(identifier)
        Player.Functions.AddItem(passed.item, amount)

        return true
    elseif (Config.Framework == "ESX") then
        local xPlayer = ESX.GetPlayerFromId(identifier)
        xPlayer.addInventoryItem(passed.item, amount)

        return true
    end
end

function Functions.RemoveItem(identifier, passed)
    if (passed.item == nil) then return false end

    local amount = passed.amount or 1

    if (Config.Framework == "QBCore") then
        local Player = QBCore.Functions.GetPlayer(identifier)
        Player.Functions.RemoveItem(passed.item, amount)

        return true
    elseif (Config.Framework == "ESX") then
        local xPlayer = ESX.GetPlayerFromId(identifier)
        xPlayer.removeInventoryItem(passed.item, amount)

        return true
    end
end

exports("Fetch", Fetch)