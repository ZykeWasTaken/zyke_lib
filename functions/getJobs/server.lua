-- Returns a raw table of the jobs

---@return table @Raw table of jobs
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getJobs()
    if (Framework == "ESX") then return ESX.GetJobs() end
    if (Framework == "QB") then return QB.Shared.Jobs end

    return {}
end

Functions.callback.register(ResName .. ":GetJobs", function()
    return Functions.getJobs()
end)

return Functions.getJobs