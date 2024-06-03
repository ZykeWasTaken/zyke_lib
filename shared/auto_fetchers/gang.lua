GangScript = nil

local systems = {
    {fileName = "zyke_gangphone", variable = "zyke_gangphone"}
}

local isServer = IsDuplicityVersion()
for _, system in pairs(systems) do
    if (isServer) then
        AddEventHandler("onResourceStart", function(resourceName)
            if (resourceName == system.fileName) then
                GangScript = system.variable
            end
        end)
    else
        local resourceState = GetResourceState(system.fileName)

        if (resourceState == "started") then
            GangScript = system.variable
            return
        end
    end

    if (GangScript) then
        Functions.Debug("Found gang system: " .. GangScript)
    end
end