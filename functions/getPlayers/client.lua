---@param useServer boolean? @Use server to fetch the IDs, otherwise you are limited by your render distance
---@return PlayerId[]
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getPlayers(useServer)
    if (useServer) then return Functions.callback.await(ResName .. ":GetPlayers") end

    local players = {}
    local _players = GetActivePlayers()
    for i = 1, #_players do
        players[#players+1] = GetPlayerServerId(_players[i])
    end

    return players
end

return Functions.getPlayers