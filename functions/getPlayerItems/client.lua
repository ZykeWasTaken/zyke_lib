-- Flattening containers is not possible on the client-side, use the server-sided version instead

---@param toInclude string[] | string | nil @List of items to include
---@return Item[]
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getPlayerItems(toInclude)
    if (type(toInclude) == "string") then toInclude = {toInclude} end

    local _inv = Inventory

    local inventory = {}

    if (_inv == "QS") then
        inventory = exports['qs-inventory']:getUserInventory() or {}
    elseif (_inv == "TGIANN") then
        inventory = exports["tgiann-inventory"]:GetPlayerItems() or {}
    elseif (_inv == "CODEM") then
        inventory = exports["codem-inventory"]:GetClientPlayerInventory() or {}
    elseif (_inv == "OX") then
        inventory = exports["ox_inventory"]:GetPlayerItems() or {}
    else
        local player = Functions.getPlayerData()
        if (not player) then return inventory end

        if (Framework == "ESX") then
            inventory = player?.inventory or {}
        elseif (Framework == "QB") then
            inventory = player?.items or {}
        end
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

        if (toInclude and not _toInclude[item.name]) then goto continue end

        formattedInventory[#formattedInventory+1] = item

        ::continue::
    end

    return formattedInventory
end

return Functions.getPlayerItems