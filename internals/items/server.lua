-- This is a multi-solution to ensuring certain metadata exists for select items for all inventories and frameworks
-- If your inventory provides another solution, we encourage you to use it, to prevent needing to listen to these events & process items all the time
local ensuredMetadata = {}

RegisterNetEvent("zyke_lib:InventoryUpdated", function(action)
    if (not Functions.table.doesTableHaveEntries(ensuredMetadata)) then return end

    local plyId = source

    if (action == "add" or action == "update") then
        local plyInv = Functions.getPlayerItems(plyId)

        for i = 1, #plyInv do
            local item = plyInv[i]
            local name = item.name

            if (ensuredMetadata[name] == nil) then goto continue end

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
    end
end)

-- We provide a lib function to each resource
-- However, we want to sync all the metadata in our lib, as it does not need to be replicated and synced in every resource
---@param item string
---@param metadata table<string, any>
exports("EnsureMetadata", function(item, metadata)
    -- TODO merge old data with new, if different scripts wants to apply data, not needed yet

    ensuredMetadata[item] = metadata
end)