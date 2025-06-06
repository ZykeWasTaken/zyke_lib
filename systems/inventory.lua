local systems = {
    {fileName = "ox_inventory", variable = "OX"},
    {fileName = "qs-inventory", variable = "QS"},
    {fileName = "tgiann-inventory", variable = "TGIANN"},
    {fileName = "codem-inventory", variable = "CODEM"},
    {fileName = "core_inventory", variable = "C8RE"},
    {fileName = "DEFAULT_INVENTORY", variable = "DEFAULT"}
}

for i = 1, #systems do
    if (GetResourceState(systems[i].fileName) == "started") then
        Inventory = systems[i].variable

        break
    end
end

-- Correctly fetch items based on various factors

if (Inventory == "OX") then
    Items = exports["ox_inventory"]:Items()
elseif (Inventory == "TGIANN") then
    Items = exports["tgiann-inventory"]:Items()
elseif (Inventory == "CODEM") then
    Items = exports["codem-inventory"]:GetItemList()
elseif (Inventory == "QS") then
    Items = exports['qs-inventory']:GetItemList()
else
    -- ESX items only exist on the server side for some reason
    if (Framework == "ESX") then
        if (Context == "server") then
            Z.callback.register("zyke_lib:FetchItems", function()
                return ESX.Items
            end)
        else
            Items = Z.callback.await("zyke_lib:FetchItems")
        end
    elseif (Framework == "QB") then
        Items = QB.Shared.Items
    end
end

if (not Inventory) then
    Inventory = "DEFAULT"
end

-- No event catching, since this should definitely be started properly