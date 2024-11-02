---@return PlayerJob | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getJob()
    local playerData = Functions.getPlayerData()
    if (not playerData or not playerData.job) then return nil end

    return Formatting.formatPlayerJob(playerData.job)
end

return Functions.getJob