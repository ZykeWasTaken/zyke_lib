-- Import this manually earlier in the imports file or something

---@param ... string
function Functions.debug(...)
    if (not Config.Settings.debug == true) then return end

    local str = ""
    for _, arg in pairs({...}) do
        str = str .. tostring(arg) .. " "
    end

    print("^4[Debug]: ^7" .. str:sub(1, #str - 1))
end

---@param ... string
function Functions.internalDebug(...)
    if (not LibConfig.debug == true) then return end

    print("^4[Debug]: ^7" .. ...)
end

return Functions.debug