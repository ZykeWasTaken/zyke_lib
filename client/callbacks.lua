local callbacks = {}

function Functions.CreateCallback(eventName, cb)
    callbacks[eventName] = cb
end

RegisterNetEvent("zyke_lib:Callback", function(eventName, requestId, data)
    if (not callbacks[eventName]) then return error("Callback not found: " .. tostring(eventName)) end

    callbacks[eventName](function(...)
        TriggerServerEvent("zyke_lib:CallbackResponse", requestId, ...)
    end, data)
end)