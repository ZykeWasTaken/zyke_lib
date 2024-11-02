---@param player Character
---@param item string
---@param amount integer
---@param metadata table<string, any> | nil
function Functions.addItem(player, item, amount, metadata)
    local player = Functions.getPlayerData(player)
    if (not player) then return end

    local items = Formatting.formatItemInput(item, amount, metadata)

    if (Framework == "ESX") then
        for i = 1, #items do
            player.addInventoryItem(items[i].name, items[i].amount, items[i].metadata)
        end
    elseif (Framework == "QB") then
        for i = 1, #items do
            player.Functions.AddItem(items[i].name, items[i].amount, nil, items[i].metadata)
        end
    end

    return true
end

return Functions.addItem