GangScript = nil

local systems = {
    {fileName = "zyke_gangphone", variable = "zyke_gangphone"}
}

-- Track if the script is started after zyke_lib
for i = 1, #systems do
    AddEventHandler("onResourceStart", function(resourceName)
        if (resourceName == systems[i].fileName) then
            GangScript = systems[i].variable
            Functions.Debug("Found gang system: " .. GangScript)
        end
    end)
end

-- Check if the resource is already started, and if so, set it as active
for i = 1, #systems do
    if (GetResourceState(systems[i].fileName) == "started") then
        GangScript = systems[i].variable

        if (GangScript) then
            Functions.Debug("Found gang system: " .. GangScript)
            return
        end
    end
end