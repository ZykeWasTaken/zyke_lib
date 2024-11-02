-- Used mainly for ox_lib menus
-- Sometimes we may deal with the vehicle type from the server, which have other values

---@param class string
---@param useServer boolean?
---@return string
function Functions.getIconForVehicleClass(class, useServer)
    if (class == nil) then return "car" end

    -- Server uses vehicle types and can not find the vehicle classes like the client
    if (useServer) then
        local icons = {
            ["automobile"] = "car",
            ["bike"] = "motorcycle",
            ["boat"] = "sailboat",
            ["heli"] = "helicopter",
            ["plane"] = "plane",
            ["submarine"] = "ferry",
            ["trailer"] = "trailer",
            ["train"] = "train",
        }

        return icons[class] or "car"
    end

    local icons = {
        "car", -- Compacts
        "car", -- Sedans
        "car", -- SUVs
        "car", -- Coupes
        "car", -- Muscle
        "car", -- Sports Classics
        "car", -- Sports
        "car", -- Super
        "motorcycle", -- Motorcycles
        "car", -- Off-road
        "car", -- Industrial
        "car", -- Utility
        "car", -- Vans
        "bicycle", -- Cycles
        "sailboat", -- Boats
        "helicopter", -- Helicopters
        "plane", -- Planes
        "car", -- Service
        "car", -- Emergency
        "car", -- Military
        "car", -- Commercial
        "train", -- Trains
        "car" -- Open Wheel
    }

    return icons[class + 1] or "car"
end

return Functions.getIconForVehicleClass