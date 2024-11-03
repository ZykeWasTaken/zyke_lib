---@param player Character | CharacterIdentifier | PlayerId
---@return CharacterIdentifier | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getIdentifier(player)
    local playerId = Functions.getPlayerId(player)

    return playerId and Player(playerId).state["zyke_lib:identifier"] or nil
end

return Functions.getIdentifier