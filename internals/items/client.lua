-- This functionality has previously been seen on the server, but moved to the client for performance reasons
-- Previously, the server had to process everyone's inventory actions, but it is now up to the player themselves to do this
-- If something is incorrect, it will then be validated on the server side for security

-- This is a multi-solution to ensuring certain metadata exists for select items for all inventories and frameworks
-- If your inventory provides another solution, we encourage you to use it, to prevent needing to listen to these events & process items all the time
---@type table<string, table>
local ensuredMetadata = {}

-- Cache a basic array to send into the item fetcher
-- This will ensure only necessary items are included and processed
---@type string[]
local itemsToFetch = {}

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

    local plyInv = Functions.getPlayerItems(itemsToFetch)
    local modifySlots = modifiedSlotsCount > 0

    for i = 1, #plyInv do
        local item = plyInv[i]
        local name = item.name

        if (modifySlots and not modifiedSlots[tostring(item.slot)]) then goto continue end

        local missingMetadata = false
        if (item.metadata) then
            for metaKey in pairs(ensuredMetadata[name]) do
                if (not item.metadata[metaKey]) then missingMetadata = true break end
            end
        else
            missingMetadata = true
        end

        if (missingMetadata) then
            TriggerServerEvent("zyke_lib:MissingMetadata", item.slot)
        end

        ::continue::
    end
end)

AddStateBagChangeHandler("ensuredMetadata", nil, function(bagName, key, value)
    ensuredMetadata = value

    itemsToFetch = {}
    for k in pairs(value) do
        itemsToFetch[#itemsToFetch+1] = k
    end
end)