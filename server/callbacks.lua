local requests = {}
local requestId = 1

function Functions.Callback(plyId, eventName, data)
    local promise = promise.new()

    requests[requestId] = function(_data)
        promise:resolve(_data)
    end

    TriggerClientEvent("zyke_lib:Callback", plyId, eventName, requestId, data)

    requestId += 1

    Citizen.Await(promise)

    return promise.value
end

RegisterNetEvent("zyke_lib:CallbackResponse", function(_requestId, data)
    if (not requests[_requestId]) then return error("Request not found: " .. tostring(_requestId)) end

    requests[_requestId](data)
    requests[_requestId] = nil
end)