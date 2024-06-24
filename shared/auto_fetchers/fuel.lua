FuelScript = nil

local systems = {
    {fileName = "LegacyFuel", variable = "LegacyFuel"}
}

-- Track if the script is started after zyke_lib
for i = 1, #systems do
    AddEventHandler("onResourceStart", function(resourceName)
        if (resourceName == systems[i].fileName) then
            FuelScript = systems[i].variable
            Functions.Debug("Found fuel system: " .. FuelScript)
        end
    end)
end

-- Check if the resource is already started, and if so, set it as active
for i = 1, #systems do
    if (GetResourceState(systems[i].fileName) == "started") then
        FuelScript = systems[i].variable

        if (FuelScript) then
            Functions.Debug("Found fuel system: " .. FuelScript)
            return
        end
    end
end