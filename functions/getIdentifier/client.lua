---@return string | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getIdentifier()
    if (Framework == "ESX") then return Functions.getPlayerData().identifier end
    if (Framework == "QB") then return Functions.getPlayerData().citizenid end

    return nil
end

return Functions.getIdentifier