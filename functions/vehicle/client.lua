Functions.vehicle = {}

---@param ply Ped
---@param veh? Vehicle @If not provided, will ues their current vehicle
function Functions.vehicle.isDriver(ply, veh)
    if (not veh) then
        veh = GetVehiclePedIsIn(ply, false)
    end

    return GetPedInVehicleSeat(veh, -1) == ply
end

return Functions.vehicle