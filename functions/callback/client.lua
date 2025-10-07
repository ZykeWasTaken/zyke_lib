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

---@class CallbackExtras
---@field retry number | false | nil @ms, 0/false/nil for no retry, how long before retrying the same callback, used primarily for possible timing issues, like script starts & grabbing data
---@field cb function | nil @Callback to be called when the request is resolved, doesn't block flow of code

---@param event string
---@param cbExtras CallbackExtras | nil @Extra information, like a timeout, not passed to the server
---@param ... any @Arguments to be passed to the server
local function triggerServerCallback(event, cbExtras, ...)
    if (not cbExtras) then cbExtras = {} end

    local args = { ... }
    local p = cbExtras.cb and nil or promise.new()
    local prevKey = nil
    local done = false

    local function executeNewCallback()
        if (prevKey) then
            requests[prevKey] = nil
        end

        local reqId = getKey()
        prevKey = reqId

        requests[reqId] = function(res, _args)
            res = { res, _args }

            if (cbExtras.cb) then
                done = true
                cbExtras.cb(table.unpack(res))
            else
                done = true
                p:resolve(res)
            end
        end

        TriggerServerEvent(cbEvent:format(event), ResName, reqId, args and table.unpack(args))

        if (
            cbExtras.retry and
            cbExtras.retry ~= false and
            cbExtras.retry ~= nil and
            cbExtras.retry ~= 0
        ) then
            SetTimeout(cbExtras.retry, function()
                if (not done) then
                    Z.debug.internal("^1Request still exists, retrying^7", reqId)

                    executeNewCallback()
                end
            end)
        end
    end

    executeNewCallback()

    if (not cbExtras.cb) then
        return table.unpack(Citizen.Await(p))
    end
end

---@param event string
---@param ... any @Arguments to be passed to the server
---@diagnostic disable-next-line: duplicate-set-field
function Functions.callback.await(event, ...)
    return triggerServerCallback(event, nil, ...)
end

-- Support for the new cbExtras parameter
-- New function to avoid breaking old compatibility
--- Should eventually move everything to this request function, or refactor all old await functions to the new cbExtras parameter
---@param event string
---@param cbExtras CallbackExtras | nil @Extra information, like a timeout, not passed to the server
---@param ... any @Arguments to be passed to the server
---@diagnostic disable-next-line: duplicate-set-field
function Functions.callback.request(event, cbExtras, ...)
    return triggerServerCallback(event, cbExtras, ...)
end

---@diagnostic disable-next-line: duplicate-set-field
function Functions.callback.register(event, cb)
    RegisterNetEvent(cbEvent:format(event), function(reqId, ...)
        TriggerServerEvent(cbEvent:format(ResName), reqId, cb(...))
    end)
end

return Functions.callback