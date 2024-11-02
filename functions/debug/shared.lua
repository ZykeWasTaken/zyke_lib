-- Import this manually earlier in the imports file or something

---@param ... string
function Functions.debug(...)
    if (not Config.Settings.debug == true) then return end

    print("^4[Debug]: ^7" .. ...)
end

---@param ... string
function Functions.internalDebug(...)
    if (not LibConfig.debug == true) then return end

    print("^4[Debug]: ^7" .. ...)
end

return Functions.debug