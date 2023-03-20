-- Catch inventory changes
if (Config.Framework == "QBCore") then
    RegisterNetEvent("QBCore:Player:SetPlayerData", function()
        TriggerEvent("zyke_lib:InventoryUpdated")
    end)
elseif (Config.Framework == "ESX") then
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