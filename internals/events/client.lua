-- Catching events on the client to translate them

-- Framework updates
-- For QB there is no event dispatched, has to catch the SetPlayerData event
if (Inventory == "OX") then
    AddEventHandler('ox_inventory:updateInventory', function()
        TriggerEvent("zyke_lib:InventoryUpdated", "update")
        TriggerServerEvent("zyke_lib:InventoryUpdated", "update")
    end)
else
    if (Framework == "QB") then
        RegisterNetEvent("QBCore:Player:SetPlayerData", function()
            TriggerEvent("zyke_lib:InventoryUpdated", "update")
            TriggerServerEvent("zyke_lib:InventoryUpdated", "update")
        end)
    elseif (Framework == "ESX") then
        RegisterNetEvent("esx:addInventoryItem", function()
            TriggerEvent("zyke_lib:InventoryUpdated", "update")
            TriggerServerEvent("zyke_lib:InventoryUpdated", "update")
        end)

        RegisterNetEvent("esx:removeInventoryItem", function()
            TriggerEvent("zyke_lib:InventoryUpdated", "update")
            TriggerServerEvent("zyke_lib:InventoryUpdated", "update")
        end)

        RegisterNetEvent("esx:setInventoryItem", function()
            TriggerEvent("zyke_lib:InventoryUpdated", "update")
            TriggerServerEvent("zyke_lib:InventoryUpdated", "update")
        end)
    end
end

-- Character Selection
if (Framework == "QB") then
    RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
        Wait(1)

        TriggerEvent("zyke_lib:OnCharacterSelect")
    end)
elseif (Framework == "ESX") then -- Not tested (Not in use for any active releases yet)
    RegisterNetEvent("esx:playerLoaded", function()
        Wait(1)

        TriggerEvent("zyke_lib:OnCharacterSelect")
    end)
end