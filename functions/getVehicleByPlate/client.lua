---@param plate string
---@return integer | nil
function Functions.getVehicleByPlate(plate)
    local vehicles = GetGamePool("CVehicle")

    for i = 1, #vehicles do
        if (GetVehicleNumberPlateText(vehicles[i]) == plate) then
            return vehicles[i]
        end
    end

    return nil
end

return Functions.getVehicleByPlate