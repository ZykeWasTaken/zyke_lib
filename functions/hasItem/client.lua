---@param item HasItemFetch[] | HasItemFetch | {name: string, amount: integer} | string
---@param amount? integer
---@diagnostic disable-next-line: duplicate-set-field
function Functions.hasItem(item, amount)
    local items, included = Formatting.formatItemInput(item, amount)
    local playerItems = Functions.getPlayerItems(included)

    -- Iterate our items we are checking for
    -- Remove the amount as they are found in our inventory
    -- If the items end up empty, return true
    for i = #items, 1, -1 do
        for _, plyItem in pairs(playerItems) do
            if (items[i].name == plyItem.name) then
                items[i].amount -= plyItem.amount

                if (items[i].amount <= 0) then
                    table.remove(items, i)
                    break
                end
            end
        end
    end

    return #items == 0
end

return Functions.hasItem