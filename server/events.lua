CreateThread(function()
    while (Framework == nil) do Wait(100) end

    AddEventHandler("playerDropped", function()
        local player = Functions.GetPlayer(source)
        TriggerEvent("zyke_lib:PlayerDropped", player, "exit")  -- Old event, switched out to better name, kept for supporting older resources, also syncing client & server names
        TriggerEvent("zyke_lib:OnCharacterLogout", player, "exit")
    end)

    if (Framework == "QBCore") then
        AddEventHandler("QBCore:Server:OnPlayerUnload", function(src)
            local player = Functions.GetPlayer(src)
            TriggerEvent("zyke_lib:PlayerDropped", player, "unload")  -- Old event, switched out to better name, kept for supporting older resources, also syncing client & server names
            TriggerEvent("zyke_lib:OnCharacterLogout", src, "unload")
            TriggerClientEvent("zyke_lib:OnCharacterLogout", src, "unload")
        end)
    elseif (Framework == "ESX") then
        AddEventHandler("esx:playerDropped", function(src)
            TriggerEvent("zyke_lib:PlayerDropped", src, "unload")  -- Old event, switched out to better name, kept for supporting older resources, also syncing client & server names
            TriggerEvent("zyke_lib:OnCharacterLogout", src, "unload")
            TriggerClientEvent("zyke_lib:OnCharacterLogout", src, "unload")
        end)
    end

    -- When you select a character
    if (Framework == "QBCore") then
        AddEventHandler("QBCore:Server:PlayerLoaded", function(player)
            -- TODO: Add identifier state here
            local source = Functions.GetSource(player)
            if (not source) then return end

            TriggerEvent("zyke_lib:PlayerJoined", source) -- Old event, switched out to better name, kept for supporting older resources, also syncing client & server names
            TriggerEvent("zyke_lib:OnCharacterSelect", source, player)
        end)
    elseif (Framework == "ESX") then
        AddEventHandler("esx:playerLoaded", function(src, player) -- Not tested (Not in use for any active releases yet)
            Player(src).state:set("zyke_lib:identifier", player.identifier, true)
            Player(src).state:set("zyke_lib:license", Functions.GetAccountIdentifiers(src, "license"), true)

            TriggerEvent("zyke_lib:PlayerJoined", src, src, player) -- Old event, switched out to better name, kept for supporting older resources, also syncing client & server names
            TriggerEvent("zyke_lib:OnCharacterSelect", src, player)
        end)
    end

    Functions.CreateCallback("zyke_lib:FetchPlayerDetails", function(source, cb, passed)
        if (type(passed.identifier) == "table") then -- Multiple identifiers
            local identifiers = {}

            for _, identifier in pairs(passed.identifier) do
                local playerDetails = Functions.GetPlayerDetails(identifier)

                table.insert(identifiers, playerDetails)
            end

            return cb(identifiers)
        else
            return cb(Functions.GetPlayerDetails(passed.identifier)) -- Singular identifier
        end
    end)

    Functions.CreateCallback("zyke_lib:GetPlayersOnJob", function(source, cb, job, onDuty)
        return cb(Functions.GetPlayersOnJob(job, onDuty))
    end)

    Functions.CreateCallback("zyke_lib:GetItems", function(source, cb)
        return cb(ESX.Items)
    end)

    Functions.CreateCallback("zyke_lib:HasPermission", function(source, cb, permission)
        return cb(Functions.HasPermission(source, permission))
    end)

    Functions.CreateCallback("zyke_lib:CreateUniqueId", function(source, cb, data)
        return cb(Functions.CreateUniqueId(data.length))
    end)

    -- TODO: Make sure you're fetching from the correct routing session
    Functions.CreateCallback("zyke_lib:GetVehicles", function(source, cb, data)
        local vehicles = GetAllVehicles()

        -- Filter based on the options
        if (data.options) then
            local filteredVehicles = {}
            local position = data.options.pos or GetEntityCoords(GetPlayerPed(source))

            local hasToBeWithinReach = data.options.reachable or false
            local filterByStates = data.options.states or false

            for _, vehicle in pairs(vehicles) do
                if (hasToBeWithinReach) then
                    local dst = #(position - GetEntityCoords(vehicle))
                    if (dst > 350) then goto endOfLoop end
                end

                if (filterByStates) then
                    for state, requiredValue in pairs(data.options.states) do
                        local entityStateValue = Entity(vehicle)?.state?[state]

                        if (requiredValue == "none") then
                            if (entityStateValue == nil) then goto endOfLoop end
                        else
                            if (requiredValue ~= entityStateValue) then goto endOfLoop end
                        end
                    end
                end

                local vehicleDetails
                if (data.options.detailed) then
                    vehicleDetails = {
                        pos = GetEntityCoords(vehicle),
                        netId = NetworkGetNetworkIdFromEntity(vehicle),
                        plate = GetVehicleNumberPlateText(vehicle),
                        vehicleType = GetVehicleType(vehicle),
                        model = GetEntityModel(vehicle),
                        handler = vehicle,
                    }

                    if (type(data.options.detailed) == "table") then
                        if (data.options.detailed.includeStates) then
                            for state in pairs(data.options.states) do
                                vehicleDetails[state] = Entity(vehicle)?.state?[state]
                            end
                        end
                    end

                else
                    vehicleDetails = vehicle
                end

                filteredVehicles[vehicleDetails] = vehicleDetails

                ::endOfLoop::
            end

            vehicles = filteredVehicles
        end

        return cb(vehicles)
    end)

    Functions.CreateCallback("zyke_lib:ESX:FetchJobs", function(source, cb)
        return cb(ESX.GetJobs())
    end)

    Functions.CreateCallback("zyke_lib:GetPlayers", function(source, cb, data)
        return cb(GetPlayers())
    end)
end)