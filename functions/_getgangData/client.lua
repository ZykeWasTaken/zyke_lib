---@param gang string
---@return Gang | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getGangData(gang)
    if (Framework == "QB") then return Formatting.formatGang(QB.Shared.Gangs[gang]) end
    if (Framework == "ESX") then return Formatting.formatGang(Functions.callback.await(LibName .. ":GetJobData")) end
end

return Functions.getGangData