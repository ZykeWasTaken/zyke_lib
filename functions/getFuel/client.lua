---@param veh integer
---@return number
function Functions.getFuel(veh)
    if (FuelSystem == "LegacyFuel") then return Functions.numbers.round(exports["LegacyFuel"]:GetFuel(veh), 1) end

    return Functions.numbers.round(GetVehicleFuelLevel(veh), 1)
end

return Functions.getFuel