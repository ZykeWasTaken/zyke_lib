---@param entity integer
---@param dict string
---@param clip string
---@param timeout? number
function Functions.awaitingAnim(entity, dict, clip, timeout)
	Functions.loadDict(dict)

	local started = GetGameTimer()
    while (not IsEntityPlayingAnim(entity, dict, clip, 3)) do
        Wait(0)

        if (timeout and GetGameTimer() - started > timeout) then return end
    end
end

return Functions.awaitingAnim