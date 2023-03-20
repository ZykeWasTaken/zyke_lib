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