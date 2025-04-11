-- Uses the normal hasItem function, but is combined with getItem to return a string of missing items
-- This is mainly for notification purposes to easily clarify needed items for the user

---@param player Character | CharacterIdentifier | PlayerId
---@param requiredItems {name: string, amount?: integer}[]
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getMissingItems(player, requiredItems)
    local player = Functions.getPlayerData(player)
    if (not player) then return false, "MISSING PLAYER" end

    local formattedItems = Formatting.formatItemInput(requiredItems)
    local items = {}

    -- Iterate & combine amounts, since there may be duplicate items in the list
    -- This way, we can provide a cleaner notification to the user
    ---@type {[string]: integer} -- name: idx
    local itemLookup = {}
    for i = 1, #formattedItems do
        local item = formattedItems[i]
        local name = item.name

        if (not itemLookup[name]) then
            local idx = #items + 1

            itemLookup[name] = idx
            items[idx] = {
                name = name,
                amount = item.amount or 1
            }
        else
            local idx = itemLookup[name]

            items[idx].amount = items[idx].amount + (item.amount or 1)
        end
    end

    ---@type {name: string, amount: integer}[]
    local itemsMissing = {}
    for i = 1, #items do
        local item = Functions.getPlayerItem(player, items[i].name, false, true, nil)
        local remainingAmount = items[i].amount - ((item and item[1] and item[1].amount) or 0)

        if (remainingAmount > 0) then
            itemsMissing[#itemsMissing+1] = {
                name = items[i].name,
                amount = remainingAmount
            }
        end
    end

    if (#itemsMissing > 0) then
        local missingItemsStr = ""
        for i = 1, #itemsMissing do
            local item = Functions.getItem(itemsMissing[i].name)
            if (not item) then error(("MISSING ITEM %s"):format(itemsMissing[i].name)) return false end

            missingItemsStr = missingItemsStr .. itemsMissing[i].amount .. "x " .. item.label .. ", "
        end

        missingItemsStr = missingItemsStr:sub(0, #missingItemsStr - 2)

        return false, missingItemsStr
    end

    return true
end

return Functions.getMissingItems