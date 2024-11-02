---@param identifier CharacterIdentifier
---@return boolean
function Functions.isCharacterIdentifierValid(identifier)
    if (not identifier) then return false end
    if (type(identifier) ~= "string") then return false end
    if (tonumber(identifier) ~= nil) then return false end -- Verify it is not a player id as string

    local activePlayer = Functions.getPlayerData(identifier)
    if (activePlayer) then return true end

    local offlinePlayer = Functions.getOfflinePlayer(identifier)
    if (offlinePlayer) then return true end

    return false
end

return Functions.isCharacterIdentifierValid