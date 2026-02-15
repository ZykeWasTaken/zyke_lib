---@param player Character | CharacterIdentifier | PlayerId
---@param toInclude string[] | string | nil @List of items to include
---@param options? {flattenContainers?: boolean}
---@return Item[]
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getPlayerItems(player, toInclude, options)
    if (type(toInclude) == "string") then toInclude = {toInclude} end

    local _inv = Inventory

    local inventory = {}

    local plyId = Z.getPlayerId(player)
    if (not plyId) then return inventory end

    if (_inv == "QS") then
        inventory = exports['qs-inventory']:GetInventory(plyId) or {}
    elseif (_inv == "TGIANN") then
        inventory = exports["tgiann-inventory"]:GetPlayerItems(plyId) or {}
    elseif (_inv == "CODEM") then
        inventory = exports["codem-inventory"]:GetInventory(nil, plyId) or {}
    elseif (_inv == "OX") then
        inventory = exports["ox_inventory"]:GetInventory(plyId)?.items or {}
    else
        local player = Functions.getPlayerData(player)
        if (not player) then return inventory end

        if (Framework == "ESX") then
            inventory = player?.inventory or {}
        elseif (Framework == "QB") then
            inventory = player?.PlayerData?.items or {}
        end
    end

    ---@type table<string, true>
    local _toInclude = {}
    if (toInclude) then
        for i = 1, #toInclude do
            _toInclude[toInclude[i]] = true
        end
    end

    local flattenContainers = options?.flattenContainers or false

    ---@param inv table
    ---@param newInv Item[] | PlayerContainerItem[]
    ---@param currContainerId? string
    local function iterateInventory(inv, newInv, currContainerId)
        for _, _item in pairs(inv) do
            local item = Formatting.formatItem(_item)

            if (flattenContainers) then

                -- Possible future implementation for other inventory systems
                if (_inv == "OX") then
                    local containerId = item?.metadata?.container

                    if (containerId ~= nil) then
                        -- Might be able to grab it from the GetInventory export, but it didn't work from testing
                        local container = exports["ox_inventory"]:GetContainerFromSlot(plyId, item.slot)

                        if (container?.items and #container.items > 0) then
                            iterateInventory(container?.items, newInv, containerId)
                        end
                    end
                end
            end

            if (toInclude and not _toInclude[item.name]) then goto continue end

            if (currContainerId) then
                item.containerId = currContainerId
            end

            newInv[#newInv+1] = item

            ::continue::
        end
    end

    local formattedInventory = {}

    iterateInventory(inventory, formattedInventory)

    return formattedInventory
end

return Functions.getPlayerItems