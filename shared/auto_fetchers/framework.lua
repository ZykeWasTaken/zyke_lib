-- Will shuffle through top to bottom, should ensure that you find your framework automatically
-- Is your framework named something else? Make sure to fill out all values properly
-- Do not change the variables, keep them as either "QBCore" or "ESX", bsaed on your framework
local frameworks = {
    {fileName = "qb-core", variable = "QBCore", fetching = function(fileName)
        QBCore = exports[fileName]:GetCoreObject()
    end},
    {fileName = "es_extended", variable = "ESX", fetching = function(fileName)
        ESX = exports[fileName]:getSharedObject()

        -- Old way to fetch ESX below
        -- ESX = nil
        -- TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end},
}

-- Fetching your framework automatically
CreateThread(function()
    Framework = nil
    Inventory = nil

    for _, settings in pairs(frameworks) do
        local resourceState = GetResourceState(settings.fileName)

        if (resourceState == "started") then
            Framework = settings.variable

            settings.fetching(settings.fileName)
            break
        end
    end

    local oxInventory = GetResourceState("ox_inventory")
    if (oxInventory == "started") then
        Inventory = "ox_inventory"

        if (Framework == "ESX") then
            ESX.Items = exports["ox_inventory"]:Items()
        end
    end

    if (Inventory == nil) then Inventory = "default" end

    if (Framework == nil) then
        error("Could not find your framework, this is critical!")
    end
end)