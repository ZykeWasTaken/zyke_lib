-- Returns an array of player ids for bosses in a profession

---@param name string
---@param professionType "job" | "gang"
---@return PlayerId[]
function Functions.getActiveBossesForProfession(name, professionType)
    local bossRanks = Functions.getBossRanks(name, professionType)

    ---@type PlayerId[]
    local activeBosses = {}
    local players, ranks = {}, {}

    if (professionType == "job") then
        players, ranks = Functions.getPlayersOnJob(name, true)
    elseif (professionType == "gang") then
        players, ranks = Functions.getPlayersOnGang(name, true)
    end

    for i = 1, #players do
        if (bossRanks[ranks[i]]) then
            activeBosses[#activeBosses+1] = players[i]
        end
    end

    return activeBosses
end

return Functions.getActiveBossesForProfession