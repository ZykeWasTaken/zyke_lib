---@param plyId PlayerId
---@param item string
---@param amount integer
---@param slot integer
function Functions.removeFromSlot(plyId, item, amount, slot)
    if (Inventory == "OX") then
        exports["ox_inventory"]:RemoveItem(plyId, item, amount, nil, slot)

        return
    end

    local player = Functions.getPlayerData(plyId)
    if (not player) then return false, Functions.internalDebug("Player not found (CRITICAL!)") end

    if (Inventory == "QS") then
        exports["qs-inventory"]:RemoveItem(plyId, item, amount, slot)

        return
    end

    if (Framework == "QB") then
        local inv = player.PlayerData.items

        for i, itemData in pairs(inv) do
            if (itemData.slot == slot) then
                itemData.amount = itemData.amount - amount

                if (itemData.amount <= 0) then
                    inv[i] = nil
                end

                break
            end
        end

        player.Functions.SetPlayerData("items", inv)

        return
    end

    error("Your inventory does not support this function.")
end

return Functions.removeFromSlot