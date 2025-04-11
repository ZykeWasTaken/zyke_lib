-- Formatting inputted items to easily handle them throughout the library
-- Should probably just learn to use the same names for everything to avoid this, but it is what it is

-- VERIFY: MULTI METADATA SUPPORT

---@class InputtedItem
---@field name string
---@field amount? integer
---@field metadata table?

---@param item string | table
---@param amount? integer
---@return InputtedItem[] | Item[], string[]
function Formatting.formatItemInput(item, amount, metadata)
    ---@type InputtedItem[] | Item[]
    local formattedItems = {}

    ---@type string[] @Array of included item names
    local included = {}

    if (type(item) == "string") then -- Simple add to the table and return
        formattedItems[#formattedItems+1] = Formatting.formatItem({name = item, amount = amount or 1, metadata = metadata})
    else
        -- Check for various table structures
        local isArray = Functions.table.isArray(item)
        if (not isArray) then
            item = {item}
        end

        for k, v in pairs(item) do
            local isKeyName = type(k) == "string" -- Check for item:amount

            if (isKeyName) then
                local _name = k
                local _amount = isKeyName and v or 1

                ---@diagnostic disable-next-line: assign-type-mismatch
                formattedItems[#formattedItems+1] = Formatting.formatItem({name = _name, amount = _amount})
            else
                formattedItems[#formattedItems+1] = Formatting.formatItem(v)
            end
        end
    end

    for i = 1, #formattedItems do
        included[#included+1] = formattedItems[i].name
    end

    return formattedItems, included
end

return Formatting.formatItemInput