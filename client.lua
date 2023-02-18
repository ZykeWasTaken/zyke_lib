function Functions.LoadModel(mdl)
    orgMdl = mdl
    mdl = joaat(mdl)
    if IsModelValid(mdl) then
        RequestModel(mdl)
        while not HasModelLoaded(mdl) do
            Wait(10)
        end
    else
        print("This model does not exist: " .. orgMdl .. "(" .. mdl .. ")")
        return false
    end

    return true
end

function Functions.LoadAnim(anim)
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Wait(10)
    end

    return true
end

function Functions.DrawMissionText(text, height, length)
	-- 0.96, 0.5 = bottom centered
    SetTextScale(0.5, 0.5)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(length, height)
end

function Fetch()
    return Functions
end

exports("Fetch", Fetch)