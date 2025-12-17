local luaDebug = debug

--[[
    ^1 - Red
    ^2 - Green
    ^3 - Yellow
    ^4 - Blue
    ^5 - Cyan
    ^6 - Magenta
    ^7 - Light Gray
    ^8 - Dark Red
    ^9 - Dark Blue
    ^0 - White
]]

---@param prefix string
---@param ... string
local function formatDebug(prefix, ...)
    local str = ""
    for _, arg in pairs({...}) do
        str = str .. tostring(arg) .. " "
    end

    local stackSkip = 4 -- Skips the stack levels, shows up as the zyke_lib method we're importing unless adjusted
    local info = luaDebug.getinfo(stackSkip, "Sl")
    local src = info.short_src -- Source path, something like @zyke_status/server/register_statuses.lua
    local line = info.currentline

    return "^4[" .. prefix .. "]: ^0" .. str:sub(1, #str - 1) .. (" ^6(%s:%d)^0"):format(src, line)
end

---@param ... string
local function debug(...)
    if (not Config.Settings.debug == true) then return end

    print(formatDebug("DEBUG", ...))
end

Functions.debug = setmetatable({}, {
    __call = function(_, ...)
        debug(...)
    end
})

---@param ... string
function Functions.debug.internal(...)
    if (not LibConfig.debug == true) then return end

    print(formatDebug("DEBUG", ...))
end

-- Uses same debug formatting function, but lets you set the prefix & doesn't have an automatic check
---@param prefix? string
---@param ... string
function Functions.debug.plain(prefix, ...)
    print(formatDebug(prefix or "DEBUG", ...))
end

return Functions.debug