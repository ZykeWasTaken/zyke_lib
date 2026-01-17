-- Iterates all of the available seats & inserts the player passengers into an array
-- Ignores non-player entities

---@param veh Vehicle
---@return {entity: Entity, seat: number}[] | nil
function Functions.getPassengers(veh)
	if (not DoesEntityExist(veh)) then return nil end

	local vehModel <const> = GetEntityModel(veh)
	local maxSeats <const> = Z.getModelMaxSeats(vehModel)

	local passengers = {}
	for i = 1, maxSeats do
		local seatIdx <const> = i - 2 -- Vehicle seats start at -1 with the driver
		local pedInSeat <const> = GetPedInVehicleSeat(veh, seatIdx)

		-- Ensure valid player
		if (pedInSeat and DoesEntityExist(pedInSeat) and IsPedAPlayer(pedInSeat)) then
			passengers[#passengers+1] = {entity = pedInSeat, seat = seatIdx}
		end
	end

	return passengers
end

return Functions.getPassengers