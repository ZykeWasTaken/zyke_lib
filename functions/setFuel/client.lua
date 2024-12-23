---@param veh Vehicle
---@param amount number
function Functions.setFuel(veh, amount)
    if (FuelSystem == "LegacyFuel") then
        return exports["LegacyFuel"]:SetFuel(veh, amount)
    end

    SetVehicleFuelLevel(veh, amount)
end

return Functions.setFuel