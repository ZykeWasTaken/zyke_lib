-- Has to be in a loop to start properly, for some odd reason
CreateThread(function()
        AddEventHandler("playerDropped", function()
        TriggerEvent("zyke_lib:PlayerDropped", source, "exit")
    end)

    if (Framework == "QBCore") then
        AddEventHandler("QBCore:Server:OnPlayerUnload", function(src)
            TriggerEvent("zyke_lib:PlayerDropped", src, "unload")
        end)
    elseif (Framework == "ESX") then
        AddEventHandler("esx:playerDropped", function(src)
            TriggerEvent("zyke_lib:PlayerDropped", src, "unload")
        end)
    end

    -- Checking player join
    if (Framework == "QBCore") then
        AddEventHandler("QBCore:Server:PlayerLoaded", function(player)
            TriggerEvent("zyke_lib:PlayerJoined", player)
        end)
    elseif (Framework == "ESX") then
        AddEventHandler("esx:playerLoaded", function(src, player) -- Not tested (Not in use for any active releases yet)
            TriggerEvent("zyke_lib:PlayerJoined", src, src, player)
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
        print("Checking...")
        return cb(Functions.HasPermission(source, permission))
    end)

    Functions.CreateCallback("zyke_lib:CreateUniqueId", function(source, cb, data)
        return cb(Functions.CreateUniqueId(data.length))
    end)
end)