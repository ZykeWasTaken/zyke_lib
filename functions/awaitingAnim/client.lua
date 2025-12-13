---@param entity integer
---@param dict string
---@param clip string
---@param timeout? number
---@return boolean @ Whether the animation played successfully
function Functions.awaitingAnim(entity, dict, clip, timeout)
	if (not Functions.loadDict(dict)) then return false end

	local started = GetGameTimer()
    while (not IsEntityPlayingAnim(entity, dict, clip, 3)) do
        Wait(0)

        if (timeout and GetGameTimer() - started > timeout) then return false end
    end

    return true
end

return Functions.awaitingAnim