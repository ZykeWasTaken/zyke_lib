Functions.stash = {}

---@diagnostic disable-next-line: duplicate-set-field
function Functions.stash.open(invId, other)
    if (Inventory == "ox_inventory") then
        return exports["ox_inventory"]:openInventory("stash", invId)
    end

    if (Framework == "QB") then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", invId, {
            maxweight = other?.maxweight or 4000,
            slots = other?.slots or 20,
        })

        TriggerEvent("inventory:client:SetCurrentStash", invId)
    end
end

return Functions.stash