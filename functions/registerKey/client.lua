-- Keymapping

---@param id string
---@param key string
---@param description string
---@param onPress function?
---@param onRelease function?
---@param keyType string? @keyboard, mouse_button
function Functions.registerKey(id, key, description, onPress, onRelease, keyType)
    RegisterKeyMapping("+" .. id, description, keyType or "keyboard", key)

    RegisterCommand("+" .. id, function()
        HoldingKeys[id] = true

        if (onPress) then onPress() end
    end, false)

    RegisterCommand("-" .. id, function()
        HoldingKeys[id] = nil

        if (onRelease) then onRelease() end
    end, false)

    -- Removing from chat, as they can be seen with + & - as prefix along with the id
    CreateThread(function()
        Wait(1000)

        TriggerEvent("chat:removeSuggestion", "/+" .. id)
        TriggerEvent("chat:removeSuggestion", "/-" .. id)
    end)
end

return Functions.registerKey