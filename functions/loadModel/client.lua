---@param model string
---@return boolean
function Functions.loadModel(model)
    local isValid = IsModelValid(model)
    if (not isValid) then error("Tried to load invalid model: " .. model) return false end

    RequestModel(model)
    while (not HasModelLoaded(model)) do Wait(0) end

    return true
end

return Functions.loadModel