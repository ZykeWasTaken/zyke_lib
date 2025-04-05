---@param item string
---@return boolean
function Functions.isItemUnique(item)
    return Items[item] and (Items[item].unique == true or Items[item].stack == false) or false
end

return Functions.isItemUnique