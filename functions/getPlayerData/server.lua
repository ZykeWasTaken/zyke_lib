---@param player Character | CharacterIdentifier | PlayerId
---@return Character | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getPlayerData(player)
    local dataType = type(player)

    if (dataType == "table") then return player end

    if (dataType == "string") then
        if (Framework == "ESX") then return ESX.GetPlayerFromIdentifier(player) end
        if (Framework == "QB") then return QB.Functions.GetPlayerByCitizenId(player) end
    elseif (dataType == "number" or dataType == "integer") then
        if (Framework == "ESX") then return ESX.GetPlayerFromId(player) end
        if (Framework == "QB") then return QB.Functions.GetPlayer(player) end
    end

    return nil
end

return Functions.getPlayerData