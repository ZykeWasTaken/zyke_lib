---@param entity integer @Handle
---@param duration integer @Milliseconds
---@param freeze boolean?
function Functions.queueEntityRemoval(entity, duration, freeze)
    if (not DoesEntityExist(entity)) then return end

    Entity(entity).state:set("removing", duration, true)

    if (freeze == true) then
        FreezeEntityPosition(entity, true)
    end

    CreateThread(function()
        Wait(duration)

        if (not DoesEntityExist(entity)) then return end
        DeleteEntity(entity)
    end)
end

return Functions.queueEntityRemoval