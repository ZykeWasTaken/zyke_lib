---@param name string
---@param professionType "job" | "gang"
---@return table<string, true>
function Functions.getBossRanks(name, professionType)
    if (professionType == "job") then
        local jobData = Functions.getJobData(name)
        if (not jobData) then return {} end

        return Formatting.formatJob(jobData).bossRanks
    elseif (professionType == "gang") then
        local gangData = Functions.getGangData(name)
        if (not gangData) then return {} end

        return Formatting.formatGang(gangData).bossRanks
    end

    return {}
end

return Functions.getBossRanks