---@diagnostic disable-next-line: duplicate-set-field
function Functions.getGang()
    local player = Functions.getPlayerData()
    if (not player or not player.gang) then return nil end

    if (Framework == "QB") then return Formatting.formatPlayerGang(player.gang) end

    -- No native support for gangs, add your own resource in here
    if (Framework == "ESX") then
        if (GangSystem == "zyke_gangphone") then
            local gang = exports["zyke_gangphone"]:GetPlayerGangDetails()
            if (not gang) then return nil end

            return Formatting.formatPlayerGang(gang)
        end
    end

    return nil
end

return Functions.getGang