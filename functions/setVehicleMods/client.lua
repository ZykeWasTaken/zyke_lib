-- Borrowed from https://github.com/esx-framework/esx_core/blob/main/%5Bcore%5D/es_extended/client/functions.lua
-- Previously refered to their function in the base, but to skip that extra steps we pasted it into here

---@param veh integer
---@param mods table
function Functions.setVehicleMods(veh, mods)
    if (not DoesEntityExist(veh)) then return end

    local colorPrimary, colorSecondary = GetVehicleColours(veh)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(veh)
    SetVehicleModKit(veh, 0)

    if mods.plate ~= nil then
        SetVehicleNumberPlateText(veh, mods.plate)
    end
    if mods.plateIndex ~= nil then
        SetVehicleNumberPlateTextIndex(veh, mods.plateIndex)
    end
    if mods.bodyHealth ~= nil then
        SetVehicleBodyHealth(veh, mods.bodyHealth + 0.0)
    end
    if mods.engineHealth ~= nil then
        SetVehicleEngineHealth(veh, mods.engineHealth + 0.0)
    end
    if mods.tankHealth ~= nil then
        SetVehiclePetrolTankHealth(veh, mods.tankHealth + 0.0)
    end
    if mods.fuelLevel ~= nil then
        SetVehicleFuelLevel(veh, mods.fuelLevel + 0.0)
    end
    if mods.dirtLevel ~= nil then
        SetVehicleDirtLevel(veh, mods.dirtLevel + 0.0)
    end
    if mods.customPrimaryColor ~= nil then
        SetVehicleCustomPrimaryColour(veh, mods.customPrimaryColor[1], mods.customPrimaryColor[2],
            mods.customPrimaryColor[3])
    end
    if mods.customSecondaryColor ~= nil then
        SetVehicleCustomSecondaryColour(veh, mods.customSecondaryColor[1], mods.customSecondaryColor[2],
            mods.customSecondaryColor[3])
    end
    if mods.color1 ~= nil then
        SetVehicleColours(veh, mods.color1, colorSecondary)
    end
    if mods.color2 ~= nil then
        SetVehicleColours(veh, mods.color1 or colorPrimary, mods.color2)
    end
    if mods.pearlescentColor ~= nil then
        SetVehicleExtraColours(veh, mods.pearlescentColor, wheelColor)
    end

    if mods.interiorColor ~= nil then
        SetVehicleInteriorColor(veh, mods.interiorColor)
    end

    if mods.dashboardColor ~= nil then
        SetVehicleDashboardColor(veh, mods.dashboardColor)
    end

    if mods.wheelColor ~= nil then
        SetVehicleExtraColours(veh, mods.pearlescentColor or pearlescentColor, mods.wheelColor)
    end
    if mods.wheels ~= nil then
        SetVehicleWheelType(veh, mods.wheels)
    end
    if mods.windowTint ~= nil then
        SetVehicleWindowTint(veh, mods.windowTint)
    end

    if mods.neonEnabled ~= nil then
        SetVehicleNeonLightEnabled(veh, 0, mods.neonEnabled[1])
        SetVehicleNeonLightEnabled(veh, 1, mods.neonEnabled[2])
        SetVehicleNeonLightEnabled(veh, 2, mods.neonEnabled[3])
        SetVehicleNeonLightEnabled(veh, 3, mods.neonEnabled[4])
    end

    if mods.extras ~= nil then
        for extraId, enabled in pairs(mods.extras) do
            SetVehicleExtra(veh, tonumber(extraId), enabled and 0 or 1)
        end
    end

    if mods.neonColor ~= nil then
        SetVehicleNeonLightsColour(veh, mods.neonColor[1], mods.neonColor[2], mods.neonColor[3])
    end
    if mods.xenonColor ~= nil then
        SetVehicleXenonLightsColor(veh, mods.xenonColor)
    end
    if mods.customXenonColor ~= nil then
        SetVehicleXenonLightsCustomColor(veh, mods.customXenonColor[1], mods.customXenonColor[2],
            mods.customXenonColor[3])
    end
    if mods.modSmokeEnabled ~= nil then
        ToggleVehicleMod(veh, 20, true)
    end
    if mods.tyreSmokeColor ~= nil then
        SetVehicleTyreSmokeColor(veh, mods.tyreSmokeColor[1], mods.tyreSmokeColor[2], mods.tyreSmokeColor[3])
    end
    if mods.modSpoilers ~= nil then
        SetVehicleMod(veh, 0, mods.modSpoilers, false)
    end
    if mods.modFrontBumper ~= nil then
        SetVehicleMod(veh, 1, mods.modFrontBumper, false)
    end
    if mods.modRearBumper ~= nil then
        SetVehicleMod(veh, 2, mods.modRearBumper, false)
    end
    if mods.modSideSkirt ~= nil then
        SetVehicleMod(veh, 3, mods.modSideSkirt, false)
    end
    if mods.modExhaust ~= nil then
        SetVehicleMod(veh, 4, mods.modExhaust, false)
    end
    if mods.modFrame ~= nil then
        SetVehicleMod(veh, 5, mods.modFrame, false)
    end
    if mods.modGrille ~= nil then
        SetVehicleMod(veh, 6, mods.modGrille, false)
    end
    if mods.modHood ~= nil then
        SetVehicleMod(veh, 7, mods.modHood, false)
    end
    if mods.modFender ~= nil then
        SetVehicleMod(veh, 8, mods.modFender, false)
    end
    if mods.modRightFender ~= nil then
        SetVehicleMod(veh, 9, mods.modRightFender, false)
    end
    if mods.modRoof ~= nil then
        SetVehicleMod(veh, 10, mods.modRoof, false)
    end
    if mods.modEngine ~= nil then
        SetVehicleMod(veh, 11, mods.modEngine, false)
    end
    if mods.modBrakes ~= nil then
        SetVehicleMod(veh, 12, mods.modBrakes, false)
    end
    if mods.modTransmission ~= nil then
        SetVehicleMod(veh, 13, mods.modTransmission, false)
    end
    if mods.modHorns ~= nil then
        SetVehicleMod(veh, 14, mods.modHorns, false)
    end
    if mods.modSuspension ~= nil then
        SetVehicleMod(veh, 15, mods.modSuspension, false)
    end
    if mods.modArmor ~= nil then
        SetVehicleMod(veh, 16, mods.modArmor, false)
    end
    if mods.modTurbo ~= nil then
        ToggleVehicleMod(veh, 18, mods.modTurbo)
    end
    if mods.modXenon ~= nil then
        ToggleVehicleMod(veh, 22, mods.modXenon)
    end
    if mods.modFrontWheels ~= nil then
        SetVehicleMod(veh, 23, mods.modFrontWheels, false)
    end
    if mods.modBackWheels ~= nil then
        SetVehicleMod(veh, 24, mods.modBackWheels, false)
    end
    if mods.modPlateHolder ~= nil then
        SetVehicleMod(veh, 25, mods.modPlateHolder, false)
    end
    if mods.modVanityPlate ~= nil then
        SetVehicleMod(veh, 26, mods.modVanityPlate, false)
    end
    if mods.modTrimA ~= nil then
        SetVehicleMod(veh, 27, mods.modTrimA, false)
    end
    if mods.modOrnaments ~= nil then
        SetVehicleMod(veh, 28, mods.modOrnaments, false)
    end
    if mods.modDashboard ~= nil then
        SetVehicleMod(veh, 29, mods.modDashboard, false)
    end
    if mods.modDial ~= nil then
        SetVehicleMod(veh, 30, mods.modDial, false)
    end
    if mods.modDoorSpeaker ~= nil then
        SetVehicleMod(veh, 31, mods.modDoorSpeaker, false)
    end
    if mods.modSeats ~= nil then
        SetVehicleMod(veh, 32, mods.modSeats, false)
    end
    if mods.modSteeringWheel ~= nil then
        SetVehicleMod(veh, 33, mods.modSteeringWheel, false)
    end
    if mods.modShifterLeavers ~= nil then
        SetVehicleMod(veh, 34, mods.modShifterLeavers, false)
    end
    if mods.modAPlate ~= nil then
        SetVehicleMod(veh, 35, mods.modAPlate, false)
    end
    if mods.modSpeakers ~= nil then
        SetVehicleMod(veh, 36, mods.modSpeakers, false)
    end
    if mods.modTrunk ~= nil then
        SetVehicleMod(veh, 37, mods.modTrunk, false)
    end
    if mods.modHydrolic ~= nil then
        SetVehicleMod(veh, 38, mods.modHydrolic, false)
    end
    if mods.modEngineBlock ~= nil then
        SetVehicleMod(veh, 39, mods.modEngineBlock, false)
    end
    if mods.modAirFilter ~= nil then
        SetVehicleMod(veh, 40, mods.modAirFilter, false)
    end
    if mods.modStruts ~= nil then
        SetVehicleMod(veh, 41, mods.modStruts, false)
    end
    if mods.modArchCover ~= nil then
        SetVehicleMod(veh, 42, mods.modArchCover, false)
    end
    if mods.modAerials ~= nil then
        SetVehicleMod(veh, 43, mods.modAerials, false)
    end
    if mods.modTrimB ~= nil then
        SetVehicleMod(veh, 44, mods.modTrimB, false)
    end
    if mods.modTank ~= nil then
        SetVehicleMod(veh, 45, mods.modTank, false)
    end
    if mods.modWindows ~= nil then
        SetVehicleMod(veh, 46, mods.modWindows, false)
    end

    if mods.modLivery ~= nil then
        SetVehicleMod(veh, 48, mods.modLivery, false)
        SetVehicleLivery(veh, mods.modLivery)
    end

    if mods.windowsBroken ~= nil then
        for k, v in pairs(mods.windowsBroken) do
            if v then
                SmashVehicleWindow(veh, tonumber(k))
            end
        end
    end

    if mods.doorsBroken ~= nil then
        for k, v in pairs(mods.doorsBroken) do
            if v then
                SetVehicleDoorBroken(veh, tonumber(k), true)
            end
        end
    end

    if mods.tyreBurst ~= nil then
        for k, v in pairs(mods.tyreBurst) do
            if v then
                SetVehicleTyreBurst(veh, tonumber(k), true, 1000.0)
            end
        end
    end
end

return Functions.setVehicleMods