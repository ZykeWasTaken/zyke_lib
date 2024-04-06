local systems = {
    {fileName = "ox_target", variable = "ox_target"},
    {fileName = "qb-target", variable = "qb-target"},
}

for _, system in pairs(systems) do
    local resourceState = GetResourceState(system.fileName)

    if (resourceState == "started") then
        Functions.Debug("Found targeting system: " .. system.fileName)
        Config.Target = system.variable
        return
    end
end