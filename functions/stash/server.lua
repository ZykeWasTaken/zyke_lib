Functions.stash = {}

-- If your inventory requires you to register the stash, it is done in here
---@param id string
---@param label string
---@param slots integer
---@param weight integer @ Grams
function Functions.stash.register(id, label, slots, weight)
    if (Inventory == "OX") then
        local stash = Functions.stash.get(id)

        if (not stash) then
            exports["ox_inventory"]:RegisterStash(id, label, slots, weight)
        end

        return
    end
end

---@param id string
---@param plyId integer
---@diagnostic disable-next-line: duplicate-set-field
function Functions.stash.open(id, plyId)
    if (Inventory == "OX") then
        return exports["ox_inventory"]:forceOpenInventory(plyId, "stash", id)
    end
end

---@param id string
---@return table?
function Functions.stash.get(id)
    if (Inventory == "OX") then
        return exports["ox_inventory"]:GetInventory(id)
    end

    return nil
end

return Functions.stash