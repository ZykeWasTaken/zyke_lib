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

-- Catch character loads
if (Config.Framework == "QBCore") then
    RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
        TriggerEvent("zyke_lib:CharacterLoaded")
    end)
elseif (Config.Framework == "ESX") then -- Not tested (Not in use for any active releases yet)
    RegisterNetEvent("esx:playerLoaded", function()
        TriggerEvent("zyke_lib:CharacterLoaded")
    end)
end

RegisterNetEvent("zyke_lib:Notify", function(msg, type, length)
    Functions.Notify(msg, type, length)
end)