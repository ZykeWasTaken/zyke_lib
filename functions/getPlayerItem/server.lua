---@param player Character | CharacterIdentifier | PlayerId
---@param itemName string
---@param firstOnly? boolean @Return first item only
---@param bundle boolean? @Bundle all the items into one, to stack the amount
---@return Item[] | Item | nil @Not array when firstOnly
function Functions.getPlayerItem(player, itemName, firstOnly, bundle, metadata)
    local items = Functions.getPlayerItems(player)
    if (not items) then return nil end

    local desiredItems = {}
    for i = 1, #items do
        if (items[i].name == itemName) then
            -- TODO: Verify metadata, only used in catalytic

            if (firstOnly) then return items[i] end

            if (bundle and #desiredItems > 0) then
                desiredItems[1].amount += items[i].amount
            else
                desiredItems[#desiredItems+1] = items[i]
            end
        end
    end

    return desiredItems
end

return Functions.getPlayerItem