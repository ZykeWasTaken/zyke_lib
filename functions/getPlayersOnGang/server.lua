---@param gang string | string[]
---@param getRanks boolean? @Get the rank name for each index in a ranks array
---@return PlayerId[], string[]
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getPlayersOnGang(gang, getRanks)
    ---@type PlayerId[]
    local playersOnGang = {}

    ---@type string[]
    local ranks = {}

    ---@param name string
    local function insertRank(name)
        if (not getRanks) then return end

        ranks[#ranks+1] = name
    end

    local players = Functions.getPlayers()
    for i = 1, #players do
        local plyGang = Functions.getGang(players[i])
        if (not plyGang) then goto continue end

        if (type(gang) == "string") then
            if (plyGang.name == gang) then
                playersOnGang[#playersOnGang+1] = players[i]
                insertRank(plyGang.grade.name)
            end
        elseif (type(gang) == "table") then
            if (Functions.table.contains(gang, plyGang.name)) then
                playersOnGang[#playersOnGang+1] = players[i]
                insertRank(plyGang.grade.name)
            end
        end

        ::continue::
    end

    return playersOnGang, ranks
end

Functions.callback.register(ResName .. ":GetPlayersOnGang", function(_, job)
    return Functions.getPlayersOnGang(job)
end)

return Functions.getPlayersOnGang