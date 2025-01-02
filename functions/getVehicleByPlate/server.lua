---@param plate string
---@return Vehicle | nil, NetId | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getVehicleByPlate(plate)
    local vehicles = GetAllVehicles()

    for i = 1, #vehicles do
        if (GetVehicleNumberPlateText(vehicles[i]) == plate) then
            return vehicles[i], NetworkGetNetworkIdFromEntity(vehicles[i])
        end
    end

    return nil, nil
end

return Functions.getVehicleByPlate