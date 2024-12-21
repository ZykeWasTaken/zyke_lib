-- The default returns a list of integers as strings
-- It messes up a lot of logic and docstrings

---@return PlayerId[]
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getPlayers()
    local players = {}

    local _players = GetPlayers()
    for i = 1, #_players do
        players[#players+1] = tonumber(_players[i])
    end

    return players
end

Functions.callback.register(ResName .. ":GetPlayers", function()
    return Functions.getPlayers()
end)

return Functions.getPlayers