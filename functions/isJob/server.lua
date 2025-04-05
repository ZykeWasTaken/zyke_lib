---@class SpecificJob
---@field name string
---@field minGrade number

---@param player Character | CharacterIdentifier | PlayerId
---@param jobs string[] | string | SpecificJob[] | SpecificJob
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
function Functions.isJob(player, jobs)
    local player = Functions.getPlayerData(player)
    if (not player) then return false end

    local plyJob = Functions.getJob(player)
    if (not plyJob) then return false end

    if (type(jobs) == "string") then -- Single job name string
        return plyJob.name == jobs
    else
        if (Functions.table.isArray(jobs)) then
            if (type(jobs[1]) == "string") then -- Array of job name strings
                return Functions.table.contains(jobs, plyJob.name)
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