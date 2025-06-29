local systems = {
    {fileName = "qs-inventory", variable = "QS"},
    {fileName = "ox_inventory", variable = "OX"},
    {fileName = "tgiann-inventory", variable = "TGIANN"},
    {fileName = "codem-inventory", variable = "CODEM"},
    {fileName = "core_inventory", variable = "C8RE"}, -- QB Only
    {fileName = "DEFAULT_INVENTORY", variable = "DEFAULT"},
}

for i = 1, #systems do
    local resState = GetResourceState(systems[i].fileName)

    -- If the resource does exist but is not started yet, we need to wait for it
    -- This is a more foolproof approach to avoid having exact resource starting sequences
    if (
        resState == "starting"
        or resState == "stopping"
        or resState == "stopped"
    ) then
        while (1) do
            resState = GetResourceState(systems[i].fileName)
             if (resState == "started") then Wait(50) break end

            Functions.debug.internal("^1Waiting for " .. systems[i].fileName .. " to start...^7")
            Wait(10)
        end
    end

    -- If it's started, we use it
    if (resState == "started") then
        Inventory = systems[i].variable
        Functions.debug.internal("^2Using " .. systems[i].fileName .. " as inventory system^7")

        break
    end
end

local items = {}
local success = false

-- See systems/framework.lua for more info on why we're doing this
repeat
    success, items = pcall(function()
        if (Inventory == "OX") then
            items = exports["ox_inventory"]:Items()
        elseif (Inventory == "TGIANN") then
            items = exports["tgiann-inventory"]:Items()
        elseif (Inventory == "CODEM") then
            items = exports["codem-inventory"]:GetItemList()
        elseif (Inventory == "QS") then
            items = exports['qs-inventory']:GetItemList()
        else
            -- ESX items only exist on the server side for some reason
            if (Framework == "ESX") then
                if (Context == "server") then
                    Z.callback.register("zyke_lib:FetchItems", function()
                        return ESX.Items
                    end)
                else
                    items = Z.callback.await("zyke_lib:FetchItems")
                end
            elseif (Framework == "QB") then
                items = QB.Shared.Items
            end
        end

        return items
    end)

    Wait(50)
until success

if (not Inventory) then
    Inventory = "DEFAULT"
end

Items = items