-- Returns an array of all player entities in the area
-- Ignores self

---@param useServer? boolean
---@param pos vector3 | Vector3Table
---@param maxDst number @400 default
---@return Entity[]
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getPlayersInArea(useServer, pos, maxDst)
    if (useServer) then return Functions.callback.await(ResName .. ":GetPlayersInArea", pos, maxDst) end

    if (not pos) then pos = GetEntityCoords(PlayerPedId()) end
    if (not maxDst) then maxDst = 400 end

    local x, y, z = pos.x, pos.y, pos.z
    local players = GetActivePlayers()
    local selfPed = PlayerPedId()

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

return Functions.getPlayersInArea