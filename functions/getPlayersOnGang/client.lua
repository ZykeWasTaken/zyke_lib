---@param gang string
---@return PlayerId[], string[]
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getPlayersOnGang(gang)
    return Functions.callback.await(ResName .. ":GetPlayersOnGang", gang)
end

return Functions.getPlayersOnGang