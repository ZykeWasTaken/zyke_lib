CreateThread(function()
    while (Framework == nil) do Wait(100) end

    local plyId = GetPlayerServerId(PlayerId())

    -- Catch inventory changes
    if (Framework == "QBCore") then
        RegisterNetEvent("QBCore:Player:SetPlayerData", function()
            TriggerEvent("zyke_lib:InventoryUpdated", "update")
            TriggerServerEvent("zyke_lib:InventoryUpdated", "update")
        end)
    elseif (Framework == "ESX") then
        RegisterNetEvent("esx:addInventoryItem", function()
            TriggerEvent("zyke_lib:InventoryUpdated", "add")
            TriggerServerEvent("zyke_lib:InventoryUpdated", "add")
        end)

        RegisterNetEvent("esx:removeInventoryItem", function()
            TriggerEvent("zyke_lib:InventoryUpdated", "remove")
            TriggerServerEvent("zyke_lib:InventoryUpdated", "remove")
        end)

        RegisterNetEvent("esx:setInventoryItem", function()
            TriggerEvent("zyke_lib:InventoryUpdated", "update")
            TriggerServerEvent("zyke_lib:InventoryUpdated", "update")
        end)
    end

    -- Catch character loads
    if (Framework == "QBCore") then
        RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
            Wait(1)

            TriggerEvent("zyke_lib:CharacterLoaded")  -- Old event, switched out to better name, kept for supporting older resources, also syncing client & server names
            TriggerEvent("zyke_lib:OnCharacterSelect")
        end)
    elseif (Framework == "ESX") then -- Not tested (Not in use for any active releases yet)
        RegisterNetEvent("esx:playerLoaded", function()
            Wait(1)

            TriggerEvent("zyke_lib:CharacterLoaded")   -- Old event, switched out to better name, kept for supporting older resources, also syncing client & server names
            TriggerEvent("zyke_lib:OnCharacterSelect")
        end)
    end

    -- Job & Gang updates
    if (Framework == "QBCore") then
        RegisterNetEvent("QBCore:Client:OnJobUpdate", function(job)
            Functions.Debug("Caught client side QB job update, sending new event...")
            TriggerEvent("zyke_lib:OnJobUpdate", Functions.FormatJob(job))
        end)

        RegisterNetEvent("QBCore:Client:OnGangUpdate", function(gang)
            Functions.Debug("Caught client side QB gang update, sending new event...")
            TriggerEvent("zyke_lib:OnGangUpdate", Functions.FormatGang(gang))
        end)
    elseif (Framework == "ESX") then
        -- Not tested (Not in use for any active releases yet)
        RegisterNetEvent("esx:setJob", function(job)
            Functions.Debug("Caught client side ESX job update, sending new event...")
            TriggerEvent("zyke_lib:OnJobUpdate", Functions.FormatJob(job))
        end)

        if (GangScript == "zyke_gangphone") then
            RegisterNetEvent("zyke_gangphone:OnGangUpdate", function(gang)
                Functions.Debug("Caught client side ESX gang update, sending new event...")
                TriggerEvent("zyke_lib:OnGangUpdate", gang) -- Already formatted
            end)
        end
    end

    RegisterNetEvent("zyke_lib:Notify", function(msg, type, length)
        Functions.Notify(msg, type, length)
    end)

    -- UI stuff
    -- Same things fetched over and over from different resources, so we'll just do it here
    RegisterNUICallback("Eventhandler", function(passed, cb)
        local event <const> = passed.event
        local data <const> = passed.data

        local e = event

        -- Event to fetch current character data for character context
        if (e == "FetchCharacter") then
            return cb(Functions.GetPlayerDetails())
        end

        error("Unknown event from " .. data._request .. " when attempting callback to NUI: " .. e)
        cb(nil)
    end)
end)