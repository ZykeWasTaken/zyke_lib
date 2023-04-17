if (Config.Framework == "QBCore") then
    QBCore = exports["qb-core"]:GetCoreObject()
elseif (Config.Fraemwork == "ESX") then
    -- OLD WAY OF FETCHING THE FRAMEWORK IS BELOW!!!
    -- If you're using an up to date server, ESX Legacy when this was created, use the fetching in your fxmanifest.lua

    -- ESX = nil
    -- TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif (Config.Framework == "QBox") then
    QBCore = exports["qbx-core"]:GetCoreObject()
end