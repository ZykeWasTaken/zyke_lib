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
            local source = Functions.GetSource(player)
            if (not source) then return end

            TriggerEvent("zyke_lib:PlayerJoined", source) -- Old event, switched out to better name, kept for supporting older resources, also syncing client & server names
            TriggerEvent("zyke_lib:OnCharacterSelect", source, source, player)
        end)
    elseif (Framework == "ESX") then
        AddEventHandler("esx:playerLoaded", function(src, player) -- Not tested (Not in use for any active releases yet)
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
end)