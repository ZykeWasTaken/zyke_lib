---@param gang string
---@return Gang | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getGangData(gang)
    if (Framework == "QB") then return Formatting.formatGang(QB.Shared.Gangs[gang]) end

    if (Framework == "ESX") then
        if (GangSystem == "zyke_gangphone") then
            return Formatting.formatGang(exports["zyke_gangphone"]:GetGang(gang))
        end
    end

    return nil
end

Functions.callback.register(LibName .. ":GetGangData", function(_, gang)
    return Functions.getGangData(gang)
end)

return Functions.getGangData