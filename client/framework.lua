if (Config.Framework == "QBCore") then
    QBCore = exports["qb-core"]:GetCoreObject()
elseif (Config.Fraemwork == "ESX") then
    return exports.es_extended:getSharedObject()
elseif (Config.Framework == "OLD") then
    TriggerEvent("esx:getSharedObject", function(obj)
        ESX = obj
elseif (Config.Framework == "QBox") then
    QBCore = exports["qbx-core"]:GetCoreObject()
end