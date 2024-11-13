---@class PlayerIdentifiers
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

---@type table<string, PlayerIdentifiers>
local playerIdentifiers = {}

local function insertIntoIdentifiers(player)
    local player = Functions.getPlayerData(player)
    if (not player) then return end

    local playerId, identifier = Functions.getPlayerId(player), Functions.getIdentifier(player)
    if (not playerId or not identifier) then return end

    local character = Functions.getCharacter(identifier)
    if (not character) then return end

    playerIdentifiers[identifier] = {
        firstname = character.firstname,
        lastname = character.lastname,
        identifier = identifier,
        source = playerId,
    }

    -- https://docs.fivem.net/docs/scripting-reference/runtimes/lua/functions/GetPlayerIdentifiers/
    for _, id in pairs(GetPlayerIdentifiers(playerId)) do
        local separator = id:find(":")
        if (separator) then
            local key = id:sub(1, separator - 1)
            local value = id:sub(separator + 1)

            playerIdentifiers[identifier][key] = value
        end
    end
end

AddEventHandler("zyke_lib:OnCharacterSelect", function(plyId, player)
    insertIntoIdentifiers(player)
end)

AddEventHandler("onResourceStart", function(resource)
    if (ResName ~= resource) then return end

    while (Framework == nil) do Wait(10) end

    local players = Functions.getPlayers()
    for i = 1, #players do
        insertIntoIdentifiers(Functions.getIdentifier(players[i]))
    end
end)

---@param identifier string
---@return PlayerIdentifiers | nil
exports("GetPlayerIdentifiers", function(identifier)
    return playerIdentifiers[identifier] or {}
end)