---@return table | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getPlayerData()
    if (Framework == "ESX") then
        local player = ESX.GetPlayerData()

        return player
    elseif (Framework == "QB") then
        local player = QB.Functions.GetPlayerData()

        return player
    end

    return nil
end

return Functions.getPlayerData