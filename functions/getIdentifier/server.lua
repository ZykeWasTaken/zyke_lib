---@param player Character | CharacterIdentifier | PlayerId
---@return CharacterIdentifier | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getIdentifier(player)
    local player = Functions.getPlayerData(player)
    if (not player) then return nil end

    if (Framework == "ESX") then return player.identifier end
    if (Framework == "QB") then return player.PlayerData.citizenid end

    return nil
end

return Functions.getIdentifier