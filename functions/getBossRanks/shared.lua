---@param name string
---@param professionType "job" | "gang"
---@return table<string, true>
function Functions.getBossRanks(name, professionType)
    if (professionType == "job") then
        return Functions.getJobData(name)?.bossRanks or {}
    elseif (professionType == "gang") then
        return Functions.getGangData(name)?.bossRanks or {}
    end

    return {}
end

return Functions.getBossRanks