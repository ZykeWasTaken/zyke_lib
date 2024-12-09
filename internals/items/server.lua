-- This is a multi-solution to ensuring certain metadata exists for select items for all inventories and frameworks
-- If your inventory provides another solution, we encourage you to use it, to prevent needing to listen to these events & process items all the time
---@type table<string, table>
local ensuredMetadata = {}

-- Cache a basic array to send into the item fetcher
-- This will ensure only necessary items are included and processed
---@type string[]
local itemsToFetch = Functions.table.new({})

---@param changes? table @Ox only
RegisterNetEvent("zyke_lib:InventoryUpdated", function(changes)
    if (#itemsToFetch <= 0) then return end

    -- Find the modified slots so we can exclusively manage them, to save performance
    ---@type table<string, string> @slot, item name
    local modifiedSlots = {}
    if (changes ~= nil) then
        for _, data in pairs(changes) do
            if (data and data.slot) then
                modifiedSlots[tostring(data.slot)] = data.name
            end
        end
    end

    local modifiedSlotsCount = Functions.table.count(modifiedSlots)

    -- If changes are defined, but none of your slots are modified
    -- This means that there is nothing we need to update
    if (changes and modifiedSlotsCount == 0) then return end

    local plyId = source
    local plyInv = Functions.getPlayerItems(plyId, itemsToFetch)
    local modifySlots = modifiedSlotsCount > 0

    for i = 1, #plyInv do
        local item = plyInv[i]
        local name = item.name

        if (modifySlots and not modifiedSlots[tostring(item.slot)]) then goto continue end

        if (not item.metadata) then item.metadata = {} end

        local newMetadata = {}
        local added = 0
        for metaKey, metaValue in pairs(ensuredMetadata[name]) do
            local metadata = item.metadata[metaKey]

            if (not metadata) then
                added += 1
            end

            local newValue = metadata == nil and metaValue or metadata

            newMetadata[metaKey] = newValue
        end

        if (added > 0) then
            Functions.setItemMetadata(plyId, item.slot, newMetadata)
            Functions.internalDebug(("Ensured missing metadata for %s."):format(name))
        end

        ::continue::
    end
end)

-- We provide a lib function to each resource
-- However, we want to sync all the metadata in our lib, as it does not need to be replicated and synced in every resource
---@param item string
---@param metadata table<string, any>
exports("EnsureMetadata", function(item, metadata)
    -- TODO merge old data with new, if different scripts wants to apply data, not needed yet

    if (not ensuredMetadata[item]) then
        itemsToFetch[#itemsToFetch+1] = item
    end

    ensuredMetadata[item] = metadata
end)