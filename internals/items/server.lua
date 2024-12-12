-- This is a multi-solution to ensuring certain metadata exists for select items for all inventories and frameworks
-- If your inventory provides another solution, we encourage you to use it, to prevent needing to listen to these events & process items all the time

---@type table<string, table>
GlobalState.ensuredMetadata = {}

-- Cache a basic array to send into the item fetcher
-- This will ensure only necessary items are included and processed
---@type string[]
local itemsToFetch = {}

---@param slot integer
RegisterNetEvent("zyke_lib:MissingMetadata", function(slot)
    local item = Functions.getInventorySlot(source, slot)
    if (not item) then return end

    local newMetadata = {}
    local added = 0
    for metaKey, metaValue in pairs(GlobalState.ensuredMetadata[item.name]) do
        local metadata = item.metadata[metaKey]

        if (not metadata) then
            added += 1
        end

        local newValue = metadata == nil and metaValue or metadata

        newMetadata[metaKey] = newValue
    end

    if (added > 0) then
        Functions.setItemMetadata(source, item.slot, newMetadata)
        Functions.internalDebug(("Ensured missing metadata for %s."):format(item.name))
    end
end)

-- We provide a lib function to each resource
-- However, we want to sync all the metadata in our lib, as it does not need to be replicated and synced in every resource
---@param item string
---@param metadata table<string, any>
exports("EnsureMetadata", function(item, metadata)
    -- TODO merge old data with new, if different scripts wants to apply data, not needed yet

    -- Some people need this check, others don't
    if (not GlobalState.ensuredMetadata) then GlobalState.ensuredMetadata = {} end

    if (not GlobalState.ensuredMetadata[item]) then
        itemsToFetch[#itemsToFetch+1] = item
    end

    local prev = GlobalState.ensuredMetadata
    prev[item] = metadata

    GlobalState:set("ensuredMetadata", prev, true)
end)