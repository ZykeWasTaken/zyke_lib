---@param dict string
---@param skipError? boolean
---@return boolean
function Functions.loadDict(dict, skipError)
    local isValid = DoesAnimDictExist(dict)
    if (not isValid) then
        if (not skipError) then
            error("Tried to load invalid animation dictionary: " .. dict)
        end

        return false
    end

    RequestAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do Wait(0) end

    return true
end

return Functions.loadDict