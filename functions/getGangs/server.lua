-- Returns a raw table of the gangs

---@return table @Raw table of gangs
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getGangs()
    if (Framework == "QB") then return QB.Shared.Gangs or {} end

    if (Framework == "ESX") then
        if (GangSystem == "zyke_gangphone") then
            return exports["zyke_gangphone"]:GetGangList() or {}
        end
    end

    return {}
end

return Functions.getGangs