---@param pos vector3 | table{x: number, y: number, z: number}
---@param dstToCheck number
---@return integer[] @Handles
function Functions.getVehiclesInArea(pos, dstToCheck)
    pos = vector3(pos.x, pos.y, pos.z)

    local inArea = {}

    local vehicles = GetAllVehicles()
    for i = 1, #vehicles do
        local veh = vehicles[i]
        local vehPos = GetEntityCoords(veh)
        local dst = #(vehPos - pos)

        if (dst <= dstToCheck) then
            inArea[#inArea+1] = vehicles[i]
        end
    end

    return inArea
end

return Functions.getVehiclesInArea