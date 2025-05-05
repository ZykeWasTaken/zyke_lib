local requests = {}
local cbEvent = "zlib:cb:%s"

Functions.callback = {}

local function getKey()
    local id

    repeat
        id = math.random(0, 1000000)
    until not requests[id]

    return id
end

RegisterNetEvent(cbEvent:format(ResName), function(reqId, ...)
    local cb = requests[reqId]
    requests[reqId] = nil

    return cb and cb(...)
end)

---@diagnostic disable-next-line: duplicate-set-field
function Functions.callback.await(event, ...)
    local promise = promise.new()
    local reqId = getKey()

    requests[reqId] = function(res, ...)
        res = { res, ... }

        promise:resolve(res)
    end

    TriggerServerEvent(cbEvent:format(event), ResName, reqId, ...)

    return table.unpack(Citizen.Await(promise))
end

---@diagnostic disable-next-line: duplicate-set-field
function Functions.callback.register(event, cb)
    RegisterNetEvent(cbEvent:format(event), function(reqId, ...)
        TriggerServerEvent(cbEvent:format(ResName), reqId, cb(...))
    end)
end

return Functions.callback