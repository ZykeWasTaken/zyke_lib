AddEventHandler("playerDropped", function()
    TriggerEvent("zyke_lib:PlayerDropped", source, "exit")
end)

if (Config.Framework == "QBCore") then
    AddEventHandler("QBCore:Server:OnPlayerUnload", function(src)
        TriggerEvent("zyke_lib:PlayerDropped", src, "unload")
    end)
elseif (Config.Framework == "ESX") then
    AddEventHandler("esx:playerDropped", function(src)
        TriggerEvent("zyke_lib:PlayerDropped", src, "unload")
    end)
end

-- Checking player join
if (Config.Framework == "QBCore") then
    AddEventHandler("QBCore:Server:PlayerLoaded", function(player)
        TriggerEvent("zyke_lib:PlayerJoined", player)
    end)
elseif (Config.Framework == "ESX") then
    AddEventHandler("esx:playerLoaded", function(src, player) -- Not tested (Not in use for any active releases yet)
        TriggerEvent("zyke_lib:PlayerJoined", src, src, player)
    end)
end