---@return Vehicle | nil, Distance | nil
function Functions.getClosestVehicle()
    local vehicles = GetGamePool("CVehicle")
    local closestVeh, closestDst = nil, nil

    local plyPos = GetEntityCoords(PlayerPedId())

    for i = 1, #vehicles do
        local dst = #(GetEntityCoords(vehicles[i]) - plyPos)

        if (closestDst == nil or dst < closestDst) then
            closestVeh = vehicles[i]
            closestDst = dst
        end
    end

    return closestVeh, closestDst
end

return Functions.getClosestVehicle