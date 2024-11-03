---@param player CharacterIdentifier | PlayerId
---@return PlayerGang | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getGang(player)
    local player = Functions.getPlayerData(player)
    if (not player) then return nil end

    if (Framework == "QB") then return Formatting.formatPlayerGang(player.gang) end

    if (Framework == "ESX") then
        if (GangSystem == "zyke_gangphone") then
            local gang = exports["zyke_gangphone"]:GetPlayerGangId(Functions.getPlayerId(player))
            if (not gang) then return nil end

            return Formatting.formatPlayerGang(gang)
        end
    end

    return nil
end

return Functions.getGang