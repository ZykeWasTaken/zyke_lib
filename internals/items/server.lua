-- This is a multi-solution to ensuring certain metadata exists for select items for all inventories and frameworks
-- If your inventory provides another solution, we encourage you to use it, to prevent needing to listen to these events & process items all the time

---@type table<string, table>
local ensuredMetadata = {}

---@param slot integer
RegisterNetEvent("zyke_lib:MissingMetadata", function(slot)
    local item = Functions.getInventorySlot(source, slot)
    if (not item) then return end

    local newMetadata = item.metadata or {}
    local added = 0
    for metaKey, metaValue in pairs(ensuredMetadata[item.name]) do
        local metadata = item.metadata[metaKey]

        if (not metadata) then
            added += 1
        end

        local newVal
        if (metadata == nil) then
            newVal = metaValue
        else
            newVal = metadata
        end

        newMetadata[metaKey] = newVal
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
    ensuredMetadata[item] = metadata

    TriggerClientEvent("zyke_lib:EnsuredMetadata", -1, ensuredMetadata)
end)

AddStateBagChangeHandler("z:hasLoaded", nil, function(bagName)
    local plyId = GetPlayerFromStateBagName(bagName)
    if (not plyId) then return end

    TriggerClientEvent("zyke_lib:EnsuredMetadata", plyId, ensuredMetadata)
end)