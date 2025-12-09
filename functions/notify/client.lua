---@param key string
---@param formatting any[]
---@param length number? @ms
---@param raw boolean? @ If true, we will not translate the key & use it as the translated string, it also does not apply any formatting
---@param _notifyType string? @ If provided, we will use it as the notification type instead of the default, primarily meant to substitute for raw
---@diagnostic disable-next-line: duplicate-set-field
function Functions.notify(key, formatting, length, raw, _notifyType)
    local notifyStr, notifyType = nil, _notifyType or "primary"
    if (raw == true) then
        notifyStr = key
    else
        notifyStr, notifyType = T(key, formatting)
    end

    if (Framework == "QB") then QB.Functions.Notify(notifyStr, notifyType, length) return end

    if (Framework == "ESX") then
        if (notifyType == "primary") then notifyType = "info" end
        if (notifyType == "warning") then notifyType = "error" end

        ESX.ShowNotification(notifyStr, notifyType, length)
        return
    end
end

RegisterNetEvent(ResName .. ":notify", function(key, formatting, length, raw, _notifyType)
    Functions.notify(key, formatting, length, raw, _notifyType)
end)

return Functions.notify