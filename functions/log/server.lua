local chunk = LoadResourceFile(LibName, ("webhooks/%s.lua"):format(TrimmedResName))
if (not chunk) then return error(("Failed to load webhooks/%s.lua. Missing webhooks?"):format(TrimmedResName)) end

local webhooks = load(chunk)()

---@alias DiscordId string @Use ROLE:x or USER:x to format, to tag properly

---@param action string
---@param handler string | integer | "server" @Identifier, player id, "server"
---@param message string
---@param rawData table | nil
---@param tag? DiscordId
---@param removeHeader? boolean
local function sendLog(action, handler, message, rawData, tag, removeHeader, messageLabel)
    local bot = {
        username = "Zyke Resources' Logs",
        avatar = "https://cdn.discordapp.com/attachments/1048900415967744031/1117129086104514721/New_Logo.png",
        webhook = webhooks[action]
    }

    if (not bot.webhook or #bot.webhook <= 0) then return end

    local handlerMsg = ""
    if (handler == nil or handler == "server") then
        handlerMsg = "Server"
    else
        local isIdentifier = type(handler) == "string"
        if (not isIdentifier) then
            handler = Functions.getIdentifier(handler) or "MISSING"
        end

        local handlerData = exports[LibName]:GetPlayerIdentifiers(handler)

        handlerMsg = handlerMsg .. (handlerData?.discord and ("<@%s>"):format(handlerData.discord) or "Missing Discord") .. " | "
        handlerMsg = handlerMsg .. (handlerData?.firstname and handlerData.firstname or "Missing first name") .. " "
        handlerMsg = handlerMsg .. (handlerData?.lastname and handlerData.lastname or "Missing last name") .. " | "
        handlerMsg = handlerMsg .. (handlerData?.identifier and handlerData.identifier or "Missing Identifier")
    end

    local fields = {
        {
            ["name"] = messageLabel or "Message",
            ["value"] = message
        },
    }

    if (not removeHeader) then
        local basicInformationStr = ""
        basicInformationStr = basicInformationStr .. "Script: " .. ResName .. "\n"
        basicInformationStr = basicInformationStr .. "Action: " .. action .. "\n"
        basicInformationStr = basicInformationStr .. "Handler: " .. handlerMsg

        table.insert(fields, 1, {
            ["name"] = "Basic Information",
            ["value"] = basicInformationStr
        })
    end

    -- Append the raw data if it exists
    if (rawData and Functions.table.count(rawData) > 0) then
        fields[#fields+1] = {
            ["name"] = "Raw Data",
            ["value"] = "```" .. json.encode(rawData, {indent = false}) .. "```",
        }
    end

    local content = ""
    if (tag) then
        for i = 1, #tag do
            local isRank = tag[i]:find("ROLE:")

            if (isRank) then
                content = content .. "<@&" .. tag[i]:sub(#"ROLE:" + 1, #tag[i]) .. ">"
            else
                content = content .. "<@" .. tag[i]:sub(#"USER:" + 1, #tag[i]) .. ">"
            end
        end
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
        avatar_url = bot.avatar,
        content = content,
    }

    PerformHttpRequest(bot.webhook, function(statusCode)
        if (statusCode ~= 204) then
            print(("Logging failed for webhook: %s"):format(bot.webhook))
        end
    end, "POST",json.encode(payload), {["Content-Type"] = "application/json"})
end

-- This is free to change, you can see all values used if you want to change it in any way
-- Keep in mind, we will not provide support for any changes made to the snippet below
local logQueue = {}
local inLogLoop = false
---@class LogData
---@field action string
---@field handler? string
---@field message string
---@field rawData table?
---@field tag? integer[] @Tags the provided discord ids
---@field removeHeader? boolean
---@field messageLabel? string

---@param passed LogData
function Functions.log(passed)
    if (type(passed) ~= "table") then error("You are attempting to log invalid data") return end -- Make sure the passed argument is a table to continue

    logQueue[#logQueue+1] = passed

    if (inLogLoop) then return end

    inLogLoop = true
    CreateThread(function()
        while (#logQueue > 0) do
            local log = logQueue[1]

            sendLog(log.action, log.handler, log.message, log.rawData, log.tag, log.removeHeader, log.messageLabel)
            table.remove(logQueue, 1)

            Wait(350) -- Ratelimit
        end

        inLogLoop = false
    end)
end

return Functions.log