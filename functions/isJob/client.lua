---@param jobs string[] | string
---@return boolean
function Functions.isJob(jobs)
    if (type(jobs) == "string") then jobs = {jobs} end

    local plyJob = Functions.getJob()
    if (not plyJob) then return false end

    return Functions.table.contains(jobs, plyJob.name)
end

return Functions.isJob