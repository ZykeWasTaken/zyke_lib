---@param player Character | CharacterIdentifier | PlayerId
---@return PlayerId | nil
function Functions.getPlayerId(player)
    if (type(player) == "number" or type(player) == "integer") then return player end

    local player = Functions.getPlayerData(player)
    if (not player) then return nil end

    if (Framework == "ESX") then return player.source end
    if (Framework == "QB") then return player.PlayerData.source end

    return nil
end

return Functions.getPlayerId