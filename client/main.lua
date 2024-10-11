-- On client start, fetch all ESX items as they can only be accessed on the server side for some reason
CreateThread(function()
    while (Framework == nil) do Wait(250) end

    if (Framework == "ESX") then
        ESX.Items = Functions.Callback("zyke_lib:GetItems", false)
    end
end)

-- Set the vehicle you are currently in as a statebag
CreateThread(function()
    local prevVeh = 0

    while (true) do
        local sleep = 250
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)

        if (prevVeh ~= veh) then
            LocalPlayer.state:set("currentVehicle", veh, false)
            prevVeh = veh
        end

        Wait(sleep)
    end
end)