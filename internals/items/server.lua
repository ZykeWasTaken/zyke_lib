-- This is a multi-solution to ensuring certain metadata exists for select items for all inventories and frameworks
-- If your inventory provides another solution, we encourage you to use it, to prevent needing to listen to these events & process items all the time

---@param val any
local function isFuncRef(val)
    if (type(val) ~= "table") then return false end

    return val["__cfx_functionReference"] ~= nil
end

---@type table<string, table | fun(): table>
local ensuredMetadata = {}

---@param slot integer
RegisterNetEvent("zyke_lib:MissingMetadata", function(slot)
    local item = Functions.getInventorySlot(source, slot)
    if (not item) then return end

    local newMetadata = item.metadata or {}
    local added = 0

    local desiredMetadata = ensuredMetadata[item.name]

    if (isFuncRef(desiredMetadata)) then
        desiredMetadata = desiredMetadata()
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    for metaKey, metaValue in pairs(desiredMetadata) do
        local metadata = item.metadata[metaKey]

        local newVal
        if (metadata == nil) then
            newVal = metaValue
            added += 1
        else
            newVal = metadata
        end

        newMetadata[metaKey] = newVal
    end

    if (added > 0) then
        Functions.setItemMetadata(source, item.slot, newMetadata)
        Functions.debug.internal(("Ensured missing metadata for %s."):format(item.name))
    end
end)

-- We provide a lib function to each resource
-- However, we want to sync all the metadata in our lib, as it does not need to be replicated and synced in every resource
---@param item string
---@param metadata table<string, any> | fun(): table<string, any>
exports("EnsureMetadata", function(item, metadata)
    ensuredMetadata[item] = metadata

    if (isFuncRef(metadata)) then
        metadata = metadata()
    end

    ---@type table<string, boolean>
    local clientData = {}
    ---@diagnostic disable-next-line: param-type-mismatch
    for k in pairs(metadata) do
        clientData[k] = true
    end

    TriggerClientEvent("zyke_lib:EnsureSingleMetadata", -1, item, clientData)
end)

---@diagnostic disable-next-line: param-type-mismatch
AddStateBagChangeHandler("z:hasLoaded", nil, function(bagName)
    local plyId = GetPlayerFromStateBagName(bagName)
    if (not plyId) then return end

    TriggerClientEvent("zyke_lib:EnsuredMetadata", plyId, ensuredMetadata)
end)