---@param gangName string
---@return Gang | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getGangData(gangName)
    local gang
    if (Framework == "QB") then
        gang = QB.Shared.Gangs[gangName]
    elseif (Framework == "ESX") then
        if (GangSystem == "zyke") then
            gang = exports["zyke_gangs"]:GetGang(gangName)
        end
    end

    if (not gang) then return nil end

    return Formatting.formatGang(gang)
end

Functions.callback.register(ResName .. ":GetGangData", function(_, gangName)
    return Functions.getGangData(gangName)
end)

return Functions.getGangData