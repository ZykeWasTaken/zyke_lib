---@param player Character | CharacterIdentifier | PlayerId
---@return PlayerJob | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getJob(player)
    local player = Functions.getPlayerData(player)
    if (not player) then return nil end

    local job
    if (Framework == "ESX") then job = player.job end
    if (Framework == "QB") then job = player.PlayerData.job end

    return Formatting.formatPlayerJob(job)
end

return Functions.getJob