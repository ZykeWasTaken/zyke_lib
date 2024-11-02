---@param text string
function Functions.copy(text)
    SendNUIMessage({
        event = "copy",
        text = text,
    })
end

return Functions.copy