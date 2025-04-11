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
    return {
        name = item.name or item.item,
        label = item.label,
        amount = item.amount or item.count or item.value or 1,
        weight = item.weight,
        metadata = item.metadata or item.info,
        slot = item.slot
    }
end

return Formatting.formatItem