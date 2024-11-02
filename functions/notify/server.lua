---@param plyId PlayerId
---@param key string
---@param formatting any[]
---@param length number? @ms
---@diagnostic disable-next-line: duplicate-set-field
function Functions.notify(plyId, key, formatting, length)
    TriggerClientEvent(ResName .. ":notify", plyId, key, formatting, length)
end

return Functions.notify