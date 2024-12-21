---@param length? integer
---@param uppercase? boolean
---@return string
---@diagnostic disable-next-line: duplicate-set-field
function Functions.createUniqueId(length, uppercase)
    if (not length) then length = 10 end

    return Functions.callback.await(ResName .. ":CreateUniqueId", length, uppercase)
end

return Functions.createUniqueId