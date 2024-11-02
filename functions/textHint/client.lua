---@param msg string
function Functions.textHint(msg)
    AddTextEntry('helpNotification', msg)
    DisplayHelpTextThisFrame('helpNotification', false)
end

return Functions.textHint