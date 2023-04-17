if (Config.Framework == "QBCore") then
    QBCore = exports["qb-core"]:GetCoreObject()
elseif (Config.Fraemwork == "ESX") then
    local ESX = exports["es_extended"]:GetSharedObject()
elseif (Config.Framework == "QBox") then
    QBCore = exports["qbx-core"]:GetCoreObject()
end