---@param pos vector3 | table{x: number, y: number, z: number}
---@param validationFn? fun(playerId: PlayerId, ped: Ped, dst: number): boolean
---@return PlayerId | -1, number | -1, boolean
function Functions.getClosestPlayerToPos(pos, validationFn)
    ---@type integer[]
    local players = Functions.getPlayers()
    local closestPly, closestDst = -1, -1

    pos = vec3(pos.x, pos.y, pos.z)

    for i = 1, #players do
        local ped = GetPlayerPed(players[i])
        local pedPos = GetEntityCoords(ped)
        local dst = #(pedPos - pos)

        if (
            (closestDst == -1 or closestDst > dst)
            ---@diagnostic disable-next-line: need-check-nil
            and (not validationFn and true or validationFn(players[i], ped, dst))
        ) then
            closestPly = players[i]
            closestDst = dst
        end
    end

    return closestPly, closestDst, closestDst < 400
end

return Functions.getClosestPlayerToPos