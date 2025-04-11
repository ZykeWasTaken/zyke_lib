---@class MetadataRequirement
---@field name string
---@field match? string | number | integer
---@field exclude? string | number | integer

---@param player Character | CharacterIdentifier | PlayerId
---@param itemName string
---@param firstOnly? boolean @Return first item only
---@param bundle? boolean @Bundle all the items into one, to stack the amount
---@param metadata? MetadataRequirement[]
---@return Item[] | Item | nil @Not array when firstOnly
function Functions.getPlayerItem(player, itemName, firstOnly, bundle, metadata)
    local items = Functions.getPlayerItems(player)
    if (not items) then return nil end

    local desiredItems = {}
    for i = 1, #items do
        if (items[i].name == itemName) then
            -- TODO: Verify metadata, only used in catalytic

            local hasAllMetadata = true
            if (metadata ~= nil) then
                for j = 1, #metadata do
                    local itemVal = items[i].metadata[metadata[j].name]
                    if (not itemVal) then hasAllMetadata = false break end

                    if (metadata[j].match ~= nil) then
                        if (metadata[j].match ~= itemVal) then hasAllMetadata = false break end
                    elseif (metadata[j].exclude ~= nil) then
                        if (metadata[j].exclude == itemVal) then hasAllMetadata = false break end
                    else
                        error("Missing metadata search type.")
                    end
                end
            end

            if (hasAllMetadata) then
                if (firstOnly) then return items[i] end

                if (bundle and #desiredItems > 0) then
                    desiredItems[1].amount += items[i].amount
                else
                    desiredItems[#desiredItems+1] = items[i]
                end
            end
        end
    end

    return desiredItems
end

return Functions.getPlayerItem