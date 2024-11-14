---@param gangName string
---@return Gang | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getGangData(gangName)
    local gang
    if (Framework == "QB") then
        gang = QB.Shared.Gangs[gangName]
    elseif (Framework == "ESX") then
        if (GangSystem == "zyke_gangphone") then
            gang = exports["zyke_gangphone"]:GetGang(gangName)
        end
    end

    if (not gang) then return nil end

    return Formatting.formatGang(gang)
end

Functions.callback.register(LibName .. ":GetGangData", function(_, gangName)
    return Functions.getGangData(gangName)
end)

return Functions.getGangData