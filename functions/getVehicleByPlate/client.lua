---@param plate string
---@return Vehicle | nil
---@diagnostic disable-next-line: duplicate-set-field
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