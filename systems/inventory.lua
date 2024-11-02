---@type string
local inventory = nil
local items = {}

local systems = {
    {fileName = "ox_inventory", variable = "OX"},
    {fileName = "qs-inventory", varialbe = "QS"},
    {fileName = "DEFAULT_INVENTORY", variable = "DEFAULT"}
}

for i = 1, #systems do
    local isStarted = GetResourceState(systems[i].fileName) == "started"

    if (isStarted) then
        inventory = systems[i].variable

        -- Functions.internalDebug("Found", inventory)

        break
    end
end

-- Correctly fetch items based on various factors

if (inventory == "OX") then
    items = exports["ox_inventory"]:Items()
else
    -- ESX items only exist on the server side for some reason
    if (Framework == "ESX") then
        if (Context == "server") then
            Z.callback.register("zyke_lib2:FetchItems", function()
                return ESX.Items
            end)
        else
            items = Z.callback.await("zyke_lib2:FetchItems")
        end
    elseif (Framework == "QB") then
        items = QB.Shared.Items
    end
end

if (not inventory) then
    inventory = "DEFAULT"
end

return inventory, items