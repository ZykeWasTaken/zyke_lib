-- Set the vehicle you are currently in
CreateThread(function()
    local prevVeh = nil

    while (true) do
        local sleep = 250
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)

        if (prevVeh ~= veh) then
            LocalPlayer.state:set("currentVehicle", veh ~= 0 and veh or nil, false)

            local netId = veh and veh ~= 0 and VehToNet(veh) or nil
            LocalPlayer.state:set("currentVehicleNetId", netId, true)

            prevVeh = veh
        end

        Wait(sleep)
    end
end)

-- Fading of vehicles that are queued to be removed (functions/queueEntityRemoval/server.lua)
---@diagnostic disable-next-line: param-type-mismatch
AddStateBagChangeHandler("removing", nil, function(bagName, _, value)
    local entity = GetEntityFromStateBagName(bagName)
    if (entity == 0 or not DoesEntityExist(entity)) then return end

    local isVeh = IsEntityAVehicle(entity)
    if (not isVeh) then return end

    SetEntityCollision(entity, false, true)
    for i = 255, 0, -1 do
        Wait(math.floor(255 / value))

        SetEntityAlpha(entity, i, false)
    end
end)

-- Verify your client has properly loaded into the game
CreateThread(function()
    LocalPlayer.state:set("z:hasLoaded", false, true) -- Needs resetting if script is restarted

    while (1) do
        local hasLoaded = NetworkIsPlayerActive(PlayerId())

        if (hasLoaded) then
            LocalPlayer.state:set("z:hasLoaded", true, true)

            break
        end

        Wait(500)
    end
end)