math.randomseed(os.time())

-- Has to have a character in the first position, otherwise there will be database errors as it removes the first sequence of numbers for some reason
-- Unsure as to what causes this issue, we will just ensure that a character is in the first position as it doesn't matter
---@param length? integer
---@param uppercase? boolean @Uppercase all characters
---@return string
---@diagnostic disable-next-line: duplicate-set-field
function Functions.createUniqueId(length, uppercase)
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
end

Z.callback.register(ResName .. ":CreateUniqueId", function(_, length, uppercase)
    return Functions.createUniqueId(length, uppercase)
end)

return Functions.createUniqueId