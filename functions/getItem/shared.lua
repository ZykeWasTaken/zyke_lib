---@param name string
---@return Item | nil
function Functions.getItem(name)
    return Items[name] and Formatting.formatItem(Items[name]) or nil
end

return Functions.getItem