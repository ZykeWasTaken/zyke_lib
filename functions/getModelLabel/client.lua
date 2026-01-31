-- Only register this callback in zyke_lib itself, not in resources that use zyke_lib
-- Otherwise every resource would register the same callback and respond to the same request
if (GetCurrentResourceName() ~= "zyke_lib") then return end

---@return table<number, string>
Z.callback.register("zyke_lib:GetVehicleModelLabels", function()
    local allModels = GetAllVehicleModels()
    local modelLabels = {}

    for i = 1, #allModels do
        local model = allModels[i]
        local modelHash = joaat(model)

        local label = GetLabelText(GetDisplayNameFromVehicleModel(modelHash))
        modelLabels[modelHash] = label
    end

    return modelLabels
end)
