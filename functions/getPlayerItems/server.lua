---@param player Character | CharacterIdentifier | PlayerId
---@param toInclude string[] | nil @List of items to include
---@return Item[]
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getPlayerItems(player, toInclude)
    local player = Functions.getPlayerData(player)
    if (not player) then return {} end

    local inventory = {}
    if (not player) then return {} end

    if (Framework == "ESX") then
        inventory = player.inventory
    elseif (Framework == "QB") then
        inventory = player.PlayerData.items
    end

    ---@type table<string, true>
    local _toInclude = {}
    if (toInclude) then
        for i = 1, #toInclude do
            _toInclude[toInclude[i]] = true
        end
    end

    local formattedInventory = {}
    for _, _item in pairs(inventory) do
        local item = Formatting.formatItem(_item)

        if (toInclude) then
            if (not _toInclude[item.name]) then goto continue end
        end

        formattedInventory[#formattedInventory+1] = item

        ::continue::
    end

    return formattedInventory
end

return Functions.getPlayerItems