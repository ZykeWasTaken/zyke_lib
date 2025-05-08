---@param key string
---@param formatting any[]
---@param length number? @ms
---@diagnostic disable-next-line: duplicate-set-field
function Functions.notify(key, formatting, length)
    local notifyStr, notifyType = T(key, formatting)

    if (Framework == "QB") then QB.Functions.Notify(notifyStr, notifyType, length) return end

    if (Framework == "ESX") then
        if (notifyType == "primary") then notifyType = "info" end
        if (notifyType == "warning") then notifyType = "error" end

        ESX.ShowNotification(notifyStr, notifyType, length)
        return
    end
end

RegisterNetEvent(ResName .. ":notify", function(key, formatting, length)
    Functions.notify(key, formatting, length)
end)

return Functions.notify