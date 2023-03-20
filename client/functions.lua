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

function Functions.Draw3DText(coords, text, scale)
    local onScreen,_x,_y=World3dToScreen2d(coords.x, coords.y, coords.z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(scale or 0.4, scale or 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end

-- The talk message top left
function Functions.HelpNoti(msg, thisFrame, beep, duration)
    AddTextEntry('helpNotification', msg)

    if thisFrame then
        DisplayHelpTextThisFrame('helpNotification', false)
    else
        if beep == nil then
            beep = true
        end
        BeginTextCommandDisplayHelp('helpNotification')
        EndTextCommandDisplayHelp(0, false, beep, duration or -1)
    end
end

function Functions.HasItem(item, amount)
    amount = amount or 1

    if (Config.Framework == "QBCore") then
        return QBCore.Functions.HasItem(item, amount)
    elseif (Config.Framework == "ESX") then
        return ESX.SearchInventory(item, amount)
    end
end

function Functions.Notify(msg, type, length)
    if (Config.Framework == "QBCore") then
        QBCore.Functions.Notify(msg, type, length)
    elseif (Config.Framework == "ESX") then
        ESX.ShowNotification(msg, type, length)
    end
end

function Functions.ProgressBar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if (Config.Framework == "QBCore") then
        QBCore.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    elseif (Config.Framework == "ESX") then
        ESX.Progressbar(label, duration, {
            animation = {
                type = animation.type,
                dict = animation.animDict,
                lib = animation.anim,
            },
            FreezePlayer = disableControls and true or false,
            onFinish = onFinish,
            onCancel = onCancel
        })
    end
end

function Functions.PlayAnim(ped, dict, anim, blendInSpeed, blendOutSpeed, duration, flag, playbackRate, lockX, lockY, lockZ)
    Functions.LoadAnim(dict)
    TaskPlayAnim(ped or PlayerPedId(), dict, anim, blendInSpeed or 8.0, blendOutSpeed or 8.0, duration, flag or 0, playbackRate or 1.0, lockX or false, lockY or false, lockZ or false)
end

function Functions.Callback(name, cb, ...)
    if (Config.Framework == "QBCore") then
        QBCore.Functions.TriggerCallback(name, cb, ...)
    elseif (Config.Framework == "ESX") then
        ESX.TriggerServerCallback(name, cb, ...)
    end
end

function Fetch()
    return Functions
end

exports("Fetch", Fetch)