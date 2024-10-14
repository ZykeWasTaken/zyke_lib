Inventory = nil

local systems = {
    {fileName = "ox_inventory", variable = "ox_inventory"},
    {fileName = "qs-inventory", variable = "qs-inventory"},
}

for i = 1, #systems do
    if (GetResourceState(systems[i].fileName) == "started") then
        Inventory = systems[i].variable

        Functions.Debug("Found inventory system: " .. Inventory)

        if (Inventory == "ox_inventory") then
            if (Framework == "ESX") then
                ESX.Items = exports["ox_inventory"]:Items()
            else
                QBCore.Shared.Items = exports["ox_inventory"]:Items()
            end
        end

        break
    end
end

if (not Inventory) then Inventory = "default" end