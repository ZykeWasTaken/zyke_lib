---@param jobName string
---@return Job | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getJobData(jobName)
    local _job
    if (Framework == "ESX") then
        return Functions.callback.await(ResName .. ":GetJobData", jobName)
    elseif (Framework == "QB") then
        _job = QB.Shared.Jobs[jobName]
    end

    if (not _job) then return nil end

    local formatted = Formatting.formatJob(_job)
    formatted.name = jobName

    return formatted
end

return Functions.getJobData