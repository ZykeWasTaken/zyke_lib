---@param pos vector3 | table{x: number, y: number, z: number}
---@return PlayerId | -1, number | -1, boolean
function Functions.getClosestPlayerToPos(pos)
    ---@type integer[]
    local players = Functions.getPlayers()
    local closestPly, closestDst = -1, -1

    pos = vec3(pos.x, pos.y, pos.z)

    for i = 1, #players do
        local ped = GetPlayerPed(players[i])
        local pedPos = GetEntityCoords(ped)
        local dst = #(pedPos - pos)

        if (closestDst == -1 or closestDst > dst) then
            closestPly = players[i]
            closestDst = dst
        end
    end

    return closestPly, closestDst, closestDst < 400
end

return Functions.getClosestPlayerToPos