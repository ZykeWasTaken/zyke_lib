---@class Item
---@field name string
---@field label string
---@field amount integer
---@field weight number
---@field metadata table<string, any> | nil
---@field slot integer

---@param item table
---@return Item
function Formatting.formatItem(item)
    local formatted = {
        name = item.name or item.item,
        label = item.label,
        amount = item.amount or item.count or item.value or 1,
        weight = item.weight,
        metadata = item.metadata or item.info,
        slot = item.slot
    }

    -- TGIANN stores both metadata & info, we need to use info here for the correct data
    -- Also check if .info exists, because if it is an internal call we may have already translated it
    if (Inventory == "TGIANN" and item.info) then
        formatted.metadata = item.info
    end

    return formatted
end

return Formatting.formatItem