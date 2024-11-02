---@param dict string
---@return boolean
function Functions.loadDict(dict)
    local isValid = DoesAnimDictExist(dict)
    if (not isValid) then error("Tried to load invalid animation dictionary: " .. dict) return false end

    RequestAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do Wait(0) end

    return true
end

return Functions.loadDict