---@param playerId PlayerId
---@return boolean
function Functions.isPlayerIdValid(playerId)
	return GetPlayerPed(playerId) ~= 0
end

return Functions.isPlayerIdValid