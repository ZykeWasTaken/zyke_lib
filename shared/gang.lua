GangScript = nil

local systems = {
    {fileName = "zyke_gangphone", variable = "zyke_gangphone"}
}

for _, system in pairs(systems) do
    AddEventHandler("onResourceStart", function(resourceName)
        if (resourceName == system.fileName) then
            Functions.Debug("Found gang system: " .. system.fileName)
            GangScript = system.variable
        end
    end)
end