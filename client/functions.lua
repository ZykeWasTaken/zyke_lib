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
        local formatted = Functions.FormatItems(item, amount)
        
        return QBCore.Functions.HasItem(formatted)
    elseif (Config.Framework == "ESX") then
        local formatted = Functions.FormatItems(item, amount)
        local hasItems = true

        for itemIdx, itemData in pairs(formatted) do
            local hasItem = ESX.SearchInventory(itemData.name, itemData.count)

            if not hasItem or hasItem == 0 then
                hasItems = false
            end
        end

        return hasItems
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

function Functions.GetPlayerData()
    if (Config.Framework == "QBCore") then
        return QBCore.Functions.GetPlayerData()
    elseif (Config.Framework == "ESX") then
        return ESX.GetPlayerData() -- Not tested (Not in use for any active releases yet)
    end
end

function Functions.GetIdentifier()
    if (Config.Framework == "QBCore") then
        return Functions.GetPlayerData().citizenid
    elseif (Config.Framework == "ESX") then
        return Functions.GetPlayerData().identifier -- Not tested (Not in use for any active releases yet)
    end
end

function Functions.OpenInventory(type, invId, other)
    type = type or "stash"
    if (Config.Framework == "QBCore") then
        TriggerServerEvent("inventory:server:OpenInventory", type, invId, {
            maxweight = other?.maxweight or 4000,
            slots = other?.slots or 20,
        })
        TriggerEvent("inventory:client:SetCurrentStash", invId)
    elseif (Config.Framework == "ESX") then
        -- TriggerEvent("esx_inventoryhud:openStashInventory", invId) -- Not tested (Not in use for any active releases yet)
    end
end

function Functions.GetJob()
    if (Config.Framework == "QBCore") then
        local job = {}

        if (Functions.GetPlayerData().job == nil) then
            return nil
        end

        -- This is to ensure my scripts align with whatever system you're using
        -- By default this will work, but if you have a different system, you can change it here
        job.name = Functions.GetPlayerData()?.job?.name or ""
        job.label = Functions.GetPlayerData()?.job?.label or ""
        job.grade = Functions.GetPlayerData()?.job?.grade or 0
        job.grade_label = Functions.GetPlayerData()?.job?.grade_label or ""
        job.grade_name = Functions.GetPlayerData()?.job?.grade_name or ""

        return job
    elseif (Config.Framework == "ESX") then
        -- return Functions.GetPlayerData()?.job -- Not tested (Not in use for any active releases yet)
        local job = {}

        if (Functions.GetPlayerData().job == nil) then
            return nil
        end

        job.name = Functions.GetPlayerData()?.job?.name or ""
        job.label = Functions.GetPlayerData()?.job?.label or ""
        job.grade = Functions.GetPlayerData()?.job?.grade or 0
        job.grade_label = Functions.GetPlayerData()?.job?.grade_label or ""
        job.grade_name = Functions.GetPlayerData()?.job?.grade_name or ""

        return job
    end
end

-- Same as above, but for gangs
function Functions.GetGang()
    if (Config.Framework == "QBCore") then
        local gang = {}

        if (Functions.GetPlayerData().gang == nil) then
            return nil
        end

        gang.name = Functions.GetPlayerData()?.gang?.name or ""
        gang.label = Functions.GetPlayerData()?.gang?.label or ""
        gang.grade = Functions.GetPlayerData()?.gang?.grade or 0
        gang.grade_label = Functions.GetPlayerData()?.gang?.grade_label or ""
        gang.grade_name = Functions.GetPlayerData()?.gang?.grade_name or ""

        return gang
    elseif (Config.Framework == "ESX") then
        return nil -- ESX doesn't have a gang system, so this will always return nil, change this if you're running one
    end
end

function Functions.HasLoadedFramework()
    if (Config.Framework == "QBCore") then
        return QBCore ~= nil
    elseif (Config.Framework == "ESX") then
        return ESX ~= nil
    end
end

-- Not used atm
function Functions.GetPlayerInventory()
    if (Config.Framework == "QBCore") then
        return Functions.GetPlayerData().items
    elseif (Config.Framework == "ESX") then
        return Functions.GetPlayerData().inventory -- Not tested (Not in use for any active releases yet)
    end
end

function Fetch()
    return Functions
end

exports("Fetch", Fetch)