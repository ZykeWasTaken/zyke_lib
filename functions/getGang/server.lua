---@param player CharacterIdentifier | PlayerId
---@return PlayerGang | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getGang(player)
    local player = Functions.getPlayerData(player)
    if (not player) then return nil end

    if (Framework == "QB") then return Formatting.formatPlayerGang(player.PlayerData.gang) end

    if (Framework == "ESX") then
        if (GangSystem == "zyke") then
            local gang = exports["zyke_gangs"]:GetPlayerGangDetails(Functions.getPlayerId(player))
            if (not gang) then return nil end

            return Formatting.formatPlayerGang(gang)
        end
    end

    return nil
end

return Functions.getGang