---@param player Character | CharacterIdentifier | PlayerId
---@return PlayerJob | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getJob(player)
    local playerData = Functions.getPlayerData(player)
    if (not playerData or not playerData.job) then return nil end

    return Formatting.formatPlayerJob(playerData.job)
end

return Functions.getJob