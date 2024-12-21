---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
function Functions.hasPermission(permission)
    return Functions.callback.await(ResName .. ":HasPermission", permission)
end

return Functions.hasPermission