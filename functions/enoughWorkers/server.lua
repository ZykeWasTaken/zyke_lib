---@param job string
---@param requirement integer
function Functions.enoughWorkers(job, requirement)
    local onJob = Functions.getPlayersOnJob(job)

    return #onJob >= requirement
end

return Functions.enoughWorkers