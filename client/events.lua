CreateThread(function()
    while (Framework == nil) do Wait(100) end

    -- Catch inventory changes
    if (Framework == "QBCore") then
        RegisterNetEvent("QBCore:Player:SetPlayerData", function()
            TriggerEvent("zyke_lib:InventoryUpdated")
        end)
    elseif (Framework == "ESX") then
        RegisterNetEvent("esx:addInventoryItem", function()
            TriggerEvent("zyke_lib:InventoryUpdated")
        end)

        RegisterNetEvent("esx:removeInventoryItem", function()
            TriggerEvent("zyke_lib:InventoryUpdated")
        end)

        RegisterNetEvent("esx:setInventoryItem", function()
            TriggerEvent("zyke_lib:InventoryUpdated")
        end)
    end

    -- Catch character loads
    if (Framework == "QBCore") then
        RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
            TriggerEvent("zyke_lib:CharacterLoaded")
        end)
    elseif (Framework == "ESX") then -- Not tested (Not in use for any active releases yet)
        RegisterNetEvent("esx:playerLoaded", function()
            TriggerEvent("zyke_lib:CharacterLoaded")
        end)
    end

    RegisterNetEvent("zyke_lib:Notify", function(msg, type, length)
        Functions.Notify(msg, type, length)
    end)
end)