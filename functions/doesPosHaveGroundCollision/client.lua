---@param pos vector3 | Vector3Table
---@return boolean
function Functions.doesPosHaveGroundCollision(pos)
    local ray = StartExpensiveSynchronousShapeTestLosProbe(pos.x, pos.y, pos.z, pos.x, pos.y, pos.z, 16, PlayerPedId(), 0)
    local _, _, _, _, result = GetShapeTestResult(ray)

    return result == 1
end

return Functions.doesPosHaveGroundCollision