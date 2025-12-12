local hasSetSeed = false

---@param length? integer
---@param uppercase? boolean
---@return string
---@diagnostic disable-next-line: duplicate-set-field
function Functions.createUniqueId(length, uppercase, useClient)
    if (not length) then length = 10 end

    if (useClient) then
        if (not hasSetSeed) then
            while (1) do
                local seed = Z.callback.await(ResName .. ":GenerateSeed")
                if (seed) then
                    math.randomseed(seed)
                    math.random()
                    hasSetSeed = true

                    break
                end
            end
        end

        length = (length or 20) - 1 -- Max characters

        local id = string.char((math.random(2) == 1 or uppercase) and math.random(65, 90) or math.random(97, 122))
        for _ = 1, length do
            local charType = math.random(uppercase and 2 or 3) -- Exclude lowercase if uppercase
            local char

            if (charType == 1) then
                char = math.random(48, 57)
            elseif (charType == 2) then
                char = math.random(65, 90)
            elseif (charType == 3) then
                char = math.random(97, 122)
            end

            id = id .. string.char(char)
        end

        return id
    else
        return Functions.callback.await(ResName .. ":CreateUniqueId", length, uppercase)
    end
end

return Functions.createUniqueId