---@param veh integer
---@param mods table
function Functions.setVehicleMods(veh, mods)
    if (not DoesEntityExist(veh)) then return end

    if (Framework == "ESX") then
        ESX.Game.SetVehicleProperties(veh, mods)
    elseif (Framework == "QB") then
        QB.Functions.SetVehicleProperties(veh, mods)
    end

    Functions.setFuel(veh, mods.fuel)

    -- Extra since depending on your ESX/QB version, this may not work as they use strings instead of integers, which is incorrect
    if (mods.windowStatus) then
        for windowId, isIntact in pairs(mods.windowStatus) do
            if (not isIntact) then
                ---@diagnostic disable-next-line: param-type-mismatch
                SmashVehicleWindow(veh, tonumber(windowId))
            end
        end
    end
end

return Functions.setVehicleMods