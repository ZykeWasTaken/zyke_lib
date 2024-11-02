Functions.numbers = {}

---@param number number
---@param decimals? integer @0 default
---@return integer | number
function Functions.numbers.round(number, decimals)
    local multiplier = 10 ^ (decimals or 0)

    return math.floor(number * multiplier + 0.5) / multiplier
end

return Functions.numbers