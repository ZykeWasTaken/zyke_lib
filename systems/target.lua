local systems = {
    {fileName = "ox_target", variable = "OX"},
    {fileName = "qb-target", variable = "QB"},
}

for i = 1, #systems do
    local resState = GetResourceState(systems[i].fileName)

    -- If the resource does exist but is not started yet, we need to wait for it
    -- This is a more foolproof approach to avoid having exact resource starting sequences
    if (
        resState == "starting"
        or resState == "stopping"
        or resState == "stopped"
    ) then
        while (1) do
            resState = GetResourceState(systems[i].fileName)
             if (resState == "started") then Wait(50) break end

            Functions.debug.internal("^1Waiting for " .. systems[i].fileName .. " to start...^7")
            Wait(10)
        end
    end

    -- If it's started, we use it
    if (resState == "started") then
        Target = systems[i].variable
        Functions.debug.internal("^2Using " .. systems[i].fileName .. " as target system^7")

        break
    end
end