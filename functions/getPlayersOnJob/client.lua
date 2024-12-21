---@param job string
---@return PlayerId[], string[]
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getPlayersOnJob(job)
    return Functions.callback.await(ResName .. ":GetPlayersOnJob", job)
end

return Functions.getPlayersOnJob