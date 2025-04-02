-- Uses the normal hasItem function, but is combined with getItem to return a string of missing items
-- This is mainly for notification purposes to easily clarify needed items for the user

-- ["missingItems"] = {msg = "You are missing items (%s)."}, -- %s = list of items

---@param requiredItems {name: string, amount: integer}[]
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getMissingItems(requiredItems)
    local player = Functions.getPlayerData()
    if (not player) then return false, "MISSING PLAYER" end

    local items = Formatting.formatItemInput(requiredItems)

    local itemsMissing = {}
    for i = 1, #items do
        local hasItem = Functions.hasItem(items[i].name, items[i].amount)
        if (not hasItem) then
            itemsMissing[#itemsMissing+1] = {
                name = items[i].name,
                amount = items[i].amount
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