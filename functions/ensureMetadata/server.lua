---@param item string
---@param metadata table<string, any>
function Functions.ensureMetadata(item, metadata)
    exports[LibName]:EnsureMetadata(item, metadata)
end

return Functions.ensureMetadata