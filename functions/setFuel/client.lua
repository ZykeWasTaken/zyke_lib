---@param veh Vehicle
---@param amount number
function Functions.setFuel(veh, amount)
    if (FuelSystem == "LegacyFuel") then return exports["LegacyFuel"]:SetFuel(veh, amount) end
    if (FuelSystem == "OX") then Entity(veh).state.fuel = amount return end
    if (FuelSystem == "CDNFuel") then return exports["cdn-fuel"]:SetFuel(veh, amount) end

    SetVehicleFuelLevel(veh, amount)
end

return Functions.setFuel