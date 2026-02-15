-- Migrated this function to use `getPlayerItems` to reduce code duplication

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
    return Functions.getPlayerItems(player, itemName, {
        firstOnly = firstOnly,
        bundle = bundle,
        metadata = metadata,
    })
end

return Functions.getPlayerItem