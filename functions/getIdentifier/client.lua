---@return string | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getIdentifier()
    return LocalPlayer.state["zyke_lib:identifier"] or nil
end

return Functions.getIdentifier