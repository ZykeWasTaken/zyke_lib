-- Borrowed from https://github.com/esx-framework/esx_core/blob/main/%5Bcore%5D/es_extended/client/functions.lua
-- Previously refered to their function in the base, but to skip that extra steps we pasted it into here

---@param veh integer
---@return table | nil
function Functions.getVehicleMods(veh)
    if (not DoesEntityExist(veh)) then return nil end

    local colorPrimary, colorSecondary = GetVehicleColours(veh)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(veh)
    local hasCustomPrimaryColor = GetIsVehiclePrimaryColourCustom(veh)
    local dashboardColor = GetVehicleDashboardColor(veh)
    local interiorColor = GetVehicleInteriorColour(veh)
    local customPrimaryColor = nil
    if hasCustomPrimaryColor then
        customPrimaryColor = {GetVehicleCustomPrimaryColour(veh)}
    end

    local hasCustomXenonColor, customXenonColorR, customXenonColorG, customXenonColorB = GetVehicleXenonLightsCustomColor(veh)
    local customXenonColor = nil
    if hasCustomXenonColor then 
        customXenonColor = {customXenonColorR, customXenonColorG, customXenonColorB}
    end

    local hasCustomSecondaryColor = GetIsVehicleSecondaryColourCustom(veh)
    local customSecondaryColor = nil
    if hasCustomSecondaryColor then
        customSecondaryColor = {GetVehicleCustomSecondaryColour(veh)}
    end

    local extras = {}
    for extraId = 0, 12 do
        if DoesExtraExist(veh, extraId) then
            extras[tostring(extraId)] = IsVehicleExtraTurnedOn(veh, extraId)
        end
    end

    local doorsBroken, windowsBroken, tyreBurst = {}, {}, {}
    local numWheels = tostring(GetVehicleNumberOfWheels(veh))

    local TyresIndex = { -- Wheel index list according to the number of vehicle wheels.
        ["2"] = {0, 4}, -- Bike and cycle.
        ["3"] = {0, 1, 4, 5}, -- Vehicle with 3 wheels (get for wheels because some 3 wheels vehicles have 2 wheels on front and one rear or the reverse).
        ["4"] = {0, 1, 4, 5}, -- Vehicle with 4 wheels.
        ["6"] = {0, 1, 2, 3, 4, 5} -- Vehicle with 6 wheels.
    }

    if TyresIndex[numWheels] then
        for tyre, idx in pairs(TyresIndex[numWheels]) do
            tyreBurst[tostring(idx)] = IsVehicleTyreBurst(veh, idx, false)
        end
    end

    for windowId = 0, 7 do -- 13
        windowsBroken[tostring(windowId)] = not IsVehicleWindowIntact(veh, windowId)
    end

    local numDoors = GetNumberOfVehicleDoors(veh)
    if numDoors and numDoors > 0 then
        for doorsId = 0, numDoors do
            doorsBroken[tostring(doorsId)] = IsVehicleDoorDamaged(veh, doorsId)
        end
    end

    local performanceMods = {
        {name = "engine", idx = 11},
        {name = "brakes", idx = 12},
        {name = "gearbox", idx = 13},
        {name = "suspension", idx = 15},
        {name = "armor", idx = 16},
        {name = "turbo", idx = 18, max = 1} -- No way to check turbo
    }

    local maxPerformanceMods = {}

    SetVehicleModKit(veh, 0)

    for _, mod in pairs(performanceMods) do
        maxPerformanceMods[mod.name] = mod.name == "turbo" and 1 or GetNumVehicleMods(veh, mod.idx)
    end

    return {
        model = GetEntityModel(veh),
        doorsBroken = doorsBroken,
        windowsBroken = windowsBroken,
        tyreBurst = tyreBurst,
        plate = GetVehicleNumberPlateText(veh),
        plateIndex = GetVehicleNumberPlateTextIndex(veh),

        bodyHealth = Functions.numbers.round(GetVehicleBodyHealth(veh), 1),
        engineHealth = Functions.numbers.round(GetVehicleEngineHealth(veh), 1),
        tankHealth = Functions.numbers.round(GetVehiclePetrolTankHealth(veh), 1),

        fuelLevel = Functions.getFuel(veh),
        dirtLevel = Functions.numbers.round(GetVehicleDirtLevel(veh), 1),

        color1 = colorPrimary,
        color2 = colorSecondary,
        customPrimaryColor = customPrimaryColor,
        customSecondaryColor = customSecondaryColor,

        pearlescentColor = pearlescentColor,
        wheelColor = wheelColor,

        dashboardColor = dashboardColor,
        interiorColor = interiorColor,

        wheels = GetVehicleWheelType(veh),
        windowTint = GetVehicleWindowTint(veh),
        xenonColor = GetVehicleXenonLightsColor(veh),
        customXenonColor = customXenonColor,

        neonEnabled = {IsVehicleNeonLightEnabled(veh, 0), IsVehicleNeonLightEnabled(veh, 1),
                        IsVehicleNeonLightEnabled(veh, 2), IsVehicleNeonLightEnabled(veh, 3)},

        neonColor = table.pack(GetVehicleNeonLightsColour(veh)),
        extras = extras,
        tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(veh)),

        modSpoilers = GetVehicleMod(veh, 0),
        modFrontBumper = GetVehicleMod(veh, 1),
        modRearBumper = GetVehicleMod(veh, 2),
        modSideSkirt = GetVehicleMod(veh, 3),
        modExhaust = GetVehicleMod(veh, 4),
        modFrame = GetVehicleMod(veh, 5),
        modGrille = GetVehicleMod(veh, 6),
        modHood = GetVehicleMod(veh, 7),
        modFender = GetVehicleMod(veh, 8),
        modRightFender = GetVehicleMod(veh, 9),
        modRoof = GetVehicleMod(veh, 10),

        modEngine = GetVehicleMod(veh, 11),
        modBrakes = GetVehicleMod(veh, 12),
        modTransmission = GetVehicleMod(veh, 13),
        modHorns = GetVehicleMod(veh, 14),
        modSuspension = GetVehicleMod(veh, 15),
        modArmor = GetVehicleMod(veh, 16),
        maxPerformanceMods = maxPerformanceMods,

        modTurbo = IsToggleModOn(veh, 18),
        modSmokeEnabled = IsToggleModOn(veh, 20),
        modXenon = IsToggleModOn(veh, 22),

        modFrontWheels = GetVehicleMod(veh, 23),
        modBackWheels = GetVehicleMod(veh, 24),

        modPlateHolder = GetVehicleMod(veh, 25),
        modVanityPlate = GetVehicleMod(veh, 26),
        modTrimA = GetVehicleMod(veh, 27),
        modOrnaments = GetVehicleMod(veh, 28),
        modDashboard = GetVehicleMod(veh, 29),
        modDial = GetVehicleMod(veh, 30),
        modDoorSpeaker = GetVehicleMod(veh, 31),
        modSeats = GetVehicleMod(veh, 32),
        modSteeringWheel = GetVehicleMod(veh, 33),
        modShifterLeavers = GetVehicleMod(veh, 34),
        modAPlate = GetVehicleMod(veh, 35),
        modSpeakers = GetVehicleMod(veh, 36),
        modTrunk = GetVehicleMod(veh, 37),
        modHydrolic = GetVehicleMod(veh, 38),
        modEngineBlock = GetVehicleMod(veh, 39),
        modAirFilter = GetVehicleMod(veh, 40),
        modStruts = GetVehicleMod(veh, 41),
        modArchCover = GetVehicleMod(veh, 42),
        modAerials = GetVehicleMod(veh, 43),
        modTrimB = GetVehicleMod(veh, 44),
        modTank = GetVehicleMod(veh, 45),
        modDoorR = GetVehicleMod(veh, 47),
        modLivery = GetVehicleMod(veh, 48) == -1 and GetVehicleLivery(veh) or GetVehicleMod(veh, 48),
        modLightbar = GetVehicleMod(veh, 49),
    }
end

return Functions.getVehicleMods