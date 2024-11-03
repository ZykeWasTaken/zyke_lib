-- Catching events on the server to translate them
AddEventHandler("playerDropped", function()
    TriggerEvent("zyke_lib:OnCharacterLogout", source, "exit")
end)

-- Unloading character
if (Framework == "QB") then
    AddEventHandler("QBCore:Server:OnPlayerUnload", function(src)
        TriggerEvent("zyke_lib:OnCharacterLogout", src, "unload")
        TriggerClientEvent("zyke_lib:OnCharacterLogout", src, "unload")
    end)
elseif (Framework == "ESX") then
    AddEventHandler("esx:playerDropped", function(src)
        TriggerEvent("zyke_lib:OnCharacterLogout", src, "unload")
        TriggerClientEvent("zyke_lib:OnCharacterLogout", src, "unload")
    end)
end

-- When you select a character
if (Framework == "QB") then
    AddEventHandler("QBCore:Server:PlayerLoaded", function(player)
        local plyId = Functions.getPlayerId(player)
        if (not plyId) then return end

        Player(plyId).state:set("zyke_lib:identifier", player.citizenid, true)
        Player(plyId).state:set("zyke_lib:license", Functions.getAccountIdentifier(plyId, "license"), true)

        TriggerEvent("zyke_lib:OnCharacterSelect", source, player)
    end)
elseif (Framework == "ESX") then
    AddEventHandler("esx:playerLoaded", function(plyId, player)
        Player(plyId).state:set("zyke_lib:identifier", player.identifier, true)
        Player(plyId).state:set("zyke_lib:license", Functions.getAccountIdentifier(plyId, "license"), true)

        TriggerEvent("zyke_lib:OnCharacterSelect", plyId, player)
    end)
end

-- Job & Gang updates
if (Framework == "QB") then
    RegisterNetEvent("QBCore:Server:OnJobUpdate", function(source, job)
        TriggerEvent("zyke_lib:OnJobUpdate", source, Formatting.formatPlayerJob(job))
        TriggerClientEvent("zyke_lib:OnJobUpdate", source, Formatting.formatPlayerJob(job))
    end)

    RegisterNetEvent("QBCore:Server:OnGangUpdate", function(source, gang)
        TriggerEvent("zyke_lib:OnGangUpdate", source, Formatting.formatGang(gang))
        TriggerClientEvent("zyke_lib:OnGangUpdate", source, Formatting.formatGang(gang))
    end)
elseif (Framework == "ESX") then
    RegisterNetEvent("esx:setJob", function(source, job)
        TriggerEvent("zyke_lib:OnJobUpdate", source, Formatting.formatPlayerJob(job))
        TriggerClientEvent("zyke_lib:OnJobUpdate", source, Formatting.formatPlayerJob(job))
    end)

    if (GangSystem == "zyke_gangphone") then
        RegisterNetEvent("zyke_gangphone:OnGangUpdate", function(source, gang)
            TriggerEvent("zyke_lib:OnGangUpdate", source, gang) -- Already formatted
            TriggerClientEvent("zyke_lib:OnGangUpdate", source, gang) -- Already formatted
        end)
    end
end