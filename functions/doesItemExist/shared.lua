---@param itemName string
---@return boolean
function Functions.doesItemExist(itemName)
	return Items[itemName] ~= nil
end

return Functions.doesItemExist