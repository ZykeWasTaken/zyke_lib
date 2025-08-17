---@param jobs string[] | string | SpecificJob[] | SpecificJob
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
function Functions.isJob(jobs)
    local plyJob = Functions.getJob()
    if (not plyJob) then return false end

    if (type(jobs) == "string") then -- Single job name string
        return plyJob.name == jobs
    else
        if (Functions.table.isArray(jobs)) then
            if (type(jobs[1]) == "string") then -- Array of job name strings
                local res = Functions.table.contains(jobs, plyJob.name)

                return res
            else -- Array of SpecificJob
                for i = 1, #jobs do
                    if (plyJob.name == jobs[i].name and plyJob.grade.level >= jobs[i].minGrade) then
                        return true
                    end
                end
            end
        else -- If solo SpecificJob
            return plyJob.name == jobs.name and plyJob.grade.level >= jobs.minGrade
        end
    end

    return false
end

return Functions.isJob