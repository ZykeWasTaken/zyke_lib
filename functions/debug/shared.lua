---@param ... string
local function debug(...)
    if (not Config.Settings.debug == true) then return end

    local str = ""
    for _, arg in pairs({...}) do
        str = str .. tostring(arg) .. " "
    end

    print("^4[Debug]: ^7" .. str:sub(1, #str - 1))
end

Functions.debug = setmetatable({}, {
    __call = function(_, ...)
        debug(...)
    end
})

---@param ... string
function Functions.debug.internal(...)
    if (not LibConfig.debug == true) then return end

    local str = ""
    for _, arg in pairs({...}) do
        str = str .. tostring(arg) .. " "
    end

    print("^4[Debug]: ^7" .. str:sub(1, #str - 1))
end

return Functions.debug