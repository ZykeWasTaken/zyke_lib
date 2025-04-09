-- Basic for now, just check if the name starts with "weapon_" / "WEAPON_"

---@param name string
function Functions.isWeapon(name)
	return name:sub(1, 7):lower() == "weapon_"
end

return Functions.isWeapon