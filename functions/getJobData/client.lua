---@param job string
---@return Job | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getJobData(job)
    if (Framework == "QB") then return Formatting.formatJob(QB.Shared.Jobs[job]) end
    if (Framework == "ESX") then return Functions.callback.await(LibName .. ":GetJobData", job) end

    return nil
end

return Functions.getJobData