-- Only register this callback in zyke_lib itself, not in resources that use zyke_lib
-- Otherwise every resource would register the same callback and respond to the same request
if GetCurrentResourceName() ~= "zyke_lib" then return end

---@return table<number, integer>
Z.callback.register("zyke_lib:GetVehicleMaxSeats", function()
    local allModels = GetAllVehicleModels()
    local maxSeats = {}

    for i = 1, #allModels do
        local model = allModels[i]
        local modelHash = joaat(model)

        local numSeats = GetVehicleModelNumberOfSeats(modelHash)
        maxSeats[modelHash] = numSeats
    end

    return maxSeats
end)
