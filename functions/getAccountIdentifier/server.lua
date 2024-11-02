---@param plyIdentifier CharacterIdentifier | PlayerId | Character
---@return string | nil
function Functions.getAccountIdentifier(plyIdentifier, desiredIdentifier)
    local plyIdentifier = Functions.getIdentifier(plyIdentifier)
    if (not plyIdentifier) then return end

    -- If it's not in here, the identifier could not be found
    return exports[LibName]:GetPlayerIdentifiers(plyIdentifier)[desiredIdentifier]
end

return Functions.getAccountIdentifier