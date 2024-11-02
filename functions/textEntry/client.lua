Functions.textEntry = {}

---@param key string
---@return string
local function getId(key)
    return ResName .. ":" .. key
end

---@param key string
---@param msg string
function Functions.textEntry.register(key, msg)
    AddTextEntry(getId(key), msg)
end

---@param key string
function Functions.textEntry.display(key)
    BeginTextCommandDisplayHelp(getId(key))
    EndTextCommandDisplayHelp(0, false, true, -1)
end

return Functions.textEntry