-- Returns an array of all player entities in the area
-- Ignores self

---@param plyId PlayerId
---@param pos vector3 | Vector3Table
---@param maxDst number @400 default
---@return Entity[]
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getPlayersInArea(plyId, pos, maxDst)
    if (not pos) then pos = GetEntityCoords(GetPlayerPed(plyId)) end
    if (not maxDst) then maxDst = 400 end

    local x, y, z = pos.x, pos.y, pos.z
    local players = GetActivePlayers()
    local selfPed = GetPlayerPed(plyId)

    local inArea = {}
    for i = 1, #players do
        local ply = GetPlayerPed(players[i])
        local targetPos = GetEntityCoords(ply)
        local dst = #(targetPos - vec3(x, y, z))

        if (selfPed ~= ply and dst <= maxDst) then
            inArea[#inArea+1] = players[i]
        end
    end

    return inArea
end

Functions.callback.register(ResName .. ":GetPlayersInArea", Functions.getPlayersInArea)

return Functions.getPlayersInArea