CreateThread(function()
    while (Framework == nil) do Wait(100) end

    AddEventHandler("playerDropped", function()
        TriggerEvent("zyke_lib:PlayerDropped", source, "exit")  -- Old event, switched out to better name, kept for supporting older resources, also syncing client & server names
        TriggerEvent("zyke_lib:OnCharacterLogout", source, "exit")
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

    -- Job & Gang updates
    if (Framework == "QBCore") then
        RegisterNetEvent("QBCore:Server:OnJobUpdate", function(source, job)
            Functions.Debug("Caught server side QB job update, sending new event...")
            TriggerEvent("zyke_lib:OnJobUpdate", source, Functions.FormatJob(job))
        end)

        RegisterNetEvent("QBCore:Server:OnGangUpdate", function(source, gang)
            Functions.Debug("Caught server side QB gang update, sending new event...")
            TriggerEvent("zyke_lib:OnGangUpdate", source, Functions.FormatGang(gang))
        end)
    elseif (Framework == "ESX") then
        RegisterNetEvent("esx:setJob", function(source, job)
            Functions.Debug("Caught server side ESX job update, sending new event...")
            TriggerEvent("zyke_lib:OnJobUpdate", source, Functions.FormatJob(job))
        end)

        if (GangScript == "zyke_gangphone") then
            RegisterNetEvent("zyke_gangphone:OnGangUpdate", function(source, gang)
                Functions.Debug("Caught server side ESX gang update, sending new event...")

                TriggerEvent("zyke_lib:OnGangUpdate", source, gang) -- Already formatted
            end)
        end
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

    Functions.CreateCallback("zyke_lib:GetVehicles", function(source, cb, data)
        return cb(Functions.GetVehicles(true, data))
    end)

    Functions.CreateCallback("zyke_lib:GetRawVehicles", function(source, cb)
        return cb(GetAllVehicles())
    end)

    Functions.CreateCallback("zyke_lib:ESX:FetchJobs", function(source, cb, data)
        if (data?.name) then
            return cb(ESX.GetJobs()[data.name])
        end

        return cb(ESX.GetJobs())
    end)

    Functions.CreateCallback("zyke_lib:GetPlayers", function(source, cb, data)
        return cb(GetPlayers())
    end)
end)