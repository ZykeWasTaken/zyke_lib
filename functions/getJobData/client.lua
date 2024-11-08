---@param job string
---@return Job | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getJobData(job)
    if (Framework == "ESX") then return Functions.callback.await(LibName .. ":GetJobData", job) end
    if (Framework == "QB") then
        local formatted = Formatting.formatJob(QB.Shared.Jobs[job])
        formatted.name = job

        return formatted
    end

    return nil
end

return Functions.getJobData