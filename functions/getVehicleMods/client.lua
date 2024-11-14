-- Borrowed from https://github.com/esx-framework/esx_core/blob/main/%5Bcore%5D/es_extended/client/functions.lua
-- Previously refered to their function in the base, but to skip that extra steps we pasted it into here

local performanceMods = {
    {name = "engine", idx = 11},
    {name = "brakes", idx = 12},
    {name = "gearbox", idx = 13},
    {name = "suspension", idx = 15},
    {name = "armor", idx = 16},
    {name = "turbo", idx = 18, max = 1} -- No way to check turbo
}

---@param veh integer
---@return table | nil
function Functions.getVehicleMods(veh)
    if (not DoesEntityExist(veh)) then return nil end

    local mods = {}
    if (Framework == "ESX") then
        mods = ESX.Game.GetVehicleProperties(veh)
    elseif (Framework == "QB") then
        mods = QB.Functions.GetVehicleProperties(veh)
    end

    local maxPerformanceMods = {}

    SetVehicleModKit(veh, 0)

    for _, mod in pairs(performanceMods) do
        maxPerformanceMods[mod.name] = mod.name == "turbo" and 1 or GetNumVehicleMods(veh, mod.idx)
    end

    mods.maxPerformanceMods = {maxPerformanceMods}

    return mods
end

return Functions.getVehicleMods