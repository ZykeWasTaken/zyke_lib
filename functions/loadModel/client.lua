---@param model string
---@param skipError? boolean
---@return boolean
function Functions.loadModel(model, skipError)
    local isValid = IsModelValid(model)
    if (not isValid) then
        if (not skipError) then
            error("Tried to load invalid model: " .. model)
        end

        return false
    end

    RequestModel(model)
    while (not HasModelLoaded(model)) do Wait(0) end

    return true
end

return Functions.loadModel