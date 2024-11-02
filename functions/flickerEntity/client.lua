-- Move this to queueEntityRemoval?
-- Send to server, validate ownership and perform the removal, as they are basically the same

---@param entity Vehicle
---@param amount integer
function Functions.flickerEntity(entity, amount)
    for i = 255, 204, -2 do
        SetEntityAlpha(entity, i, false)
        Wait(2)
    end

    while amount > 0 do
        for alpha = 204, 51, -2 do
            SetEntityAlpha(entity, alpha, false)
            Wait(2)
        end

        for alpha = 51, 204, 2 do
            SetEntityAlpha(entity, alpha, false)
            Wait(2)
        end

        amount = amount - 1
    end

    for i = 204, 0, -2 do
        SetEntityAlpha(entity, i, false)
        Wait(2)
    end

    return true
end

return Functions.flickerEntity