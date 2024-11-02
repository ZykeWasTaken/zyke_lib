---@param job string
---@return Job | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getJobData(job)
    if (Framework == "ESX") then return Formatting.formatJob(ESX.GetJobs()[job]) end
    if (Framework == "QB") then return Formatting.formatJob(QB.Shared.Jobs[job]) end

    return nil
end

Functions.callback.register(LibName .. ":GetJobData", function(_, job)
    return Functions.getJobData(job)
end)

return Functions.getJobData