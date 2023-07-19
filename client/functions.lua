function Functions.LoadModel(mdl)
    local orgMdl = mdl
    mdl = joaat(mdl)

    if (IsModelValid(mdl)) then
        RequestModel(mdl)
        while (not HasModelLoaded(mdl)) do
            Wait(10)
        end
        return true
    else
        print("This model does not exist: " .. orgMdl .. " (" .. mdl .. ")")
        return false
    end
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
    DrawText(length ~= nil and length or 0.5, height ~= nil and height or 0.96)
end

function Functions.Draw3DText(coords, text, scale)
    local onScreen,_x,_y=World3dToScreen2d(coords.x, coords.y, coords.z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(scale or 0.3, scale or 0.3)
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
    if (Config.Progressbar == "ox_lib") then
        local state = lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = useWhileDead,
            canCancel = canCancel,
            anim = {
                dict = animation.animDict,
                clip = animation.anim,
                flag = animation.flag or 49,
            }
        })

        if (state == true) then
            if (onFinish) then
                onFinish()
            end
        else
            if (onCancel) then
                onCancel()
            end
        end
    else
        canCancel = canCancel or false -- QB requires this to have a set value
        disableControls = disableControls or {} -- QB requires this to have a set value

        if (Config.Framework == "QBCore") then
            QBCore.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
        elseif (Config.Framework == "ESX") then
            ESX.Progressbar(label, duration, {
                animation = animation and {
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
end

function Functions.PlayAnim(ped, dict, anim, blendInSpeed, blendOutSpeed, duration, flag, playbackRate, lockX, lockY, lockZ)
    TaskPlayAnim(ped or PlayerPedId(), dict, anim, blendInSpeed or 8.0, blendOutSpeed or 8.0, duration, flag or 0, playbackRate or 1.0, lockX or false, lockY or false, lockZ or false)
end

function Functions.Callback(name, cb, ...)
    local promise = promise.new()
    if (Config.Framework == "QBCore") then
        QBCore.Functions.TriggerCallback(name, function(res)
            if (type(cb) == "table") then
                cb(res)
            end

            promise:resolve(res)
        end, ...)
    elseif (Config.Framework == "ESX") then
        ESX.TriggerServerCallback(name, function(res)
            if (type(cb) == "table") then
                cb(res)
            end

            promise:resolve(res)
        end, ...)
    end

    Citizen.Await(promise)
    if (cb == false) then
        -- local data = promise.value

        -- if (data == nil) then
        --     return promise
        -- else
        --     return data
        -- end

        return promise.value
    end
end

function Functions.GetPlayerData()
    if (Config.Framework == "QBCore") then
        return QBCore.Functions.GetPlayerData()
    elseif (Config.Framework == "ESX") then
        return ESX.GetPlayerData() -- Not tested (Not in use for any active releases yet) (ERROR)
    end
end

function Functions.GetIdentifier()
    if (Config.Framework == "QBCore") then
        return Functions.GetPlayerData().citizenid
    elseif (Config.Framework == "ESX") then
        return Functions.GetPlayerData().identifier -- Not tested (Not in use for any active releases yet)
    end
end

-- TODO: Fix for ESX, if even possible with default inventory?
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

        local playerData = Functions.GetPlayerData()

        -- This is to ensure my scripts align with whatever system you're using
        -- By default this will work, but if you have a different system, you can change it here
        job.name = playerData?.job?.name or ""
        job.label = playerData?.job?.label or ""
        job.grade = playerData?.job?.grade or 0
        job.grade_label = playerData?.job?.grade_label or ""
        job.grade_name = playerData?.job?.grade_name or ""

        return job
    elseif (Config.Framework == "ESX") then
        -- return Functions.GetPlayerData()?.job -- Not tested (Not in use for any active releases yet)
        local job = {}

        if (Functions.GetPlayerData().job == nil) then
            return nil
        end

        local playerData = Functions.GetPlayerData()

        job.name = playerData?.job?.name or ""
        job.label = playerData?.job?.label or ""
        job.grade = playerData?.job?.grade or 0
        job.grade_label = playerData?.job?.grade_label or ""
        job.grade_name = playerData?.job?.grade_name or ""

        return job
    end
end

function Functions.IsJob(job)
    if (type(job) == "string") then
        return Functions.GetJob().name == job
    elseif (type(job) == "table") then
        for _, jobName in pairs(job) do
            local isJob = Functions.GetJob().name == jobName

            if (isJob) then return true end
        end
    end

    return false
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

function Functions.GetClosestPlayer()
    if (Config.Framework == "QBCore") then
        return QBCore.Functions.GetClosestPlayer()
    elseif (Config.Framework == "ESX") then
        return ESX.GetClosestPlayer() -- Not tested (Not in use for any active releases yet)
    end
end

function Functions.IsPlayerDead()
    local ped = PlayerPedId()
    if (Config.Framework == "QBCore") then
        return Functions.GetPlayerData().metadata["isdead"] or Functions.GetPlayerData().metadata["inlaststand"]
    elseif (Config.Framework == "ESX") then
        return IsEntityDead(ped) -- Not tested (Not in use for any active releases yet)
    end
end

function Functions.GetPlayers()
    if (Config.Framework == "QBCore") then
        return QBCore.Functions.GetPlayers()
    elseif (Config.Framework == "ESX") then
        return ESX.GetPlayers() -- Not tested (Not in use for any active releases yet)
    end
end

function Functions.GetPlayersServerId()
    local players = Functions.GetPlayers()
    local serverIds = {}

    for _, player in pairs(players) do
        local serverId = GetPlayerServerId(player)

        table.insert(serverIds, serverId)
    end
end

--[[
    veh = vehicle handler / entity id
    mods = {
        ["engine"] = 2,
        ["suspension"] = 3,
        -- etc
    }
]]
function Functions.SetVehicleMods(veh, mods)
    local _mods = {
        ["engine"] = {idx = 11, max = 3},
        ["brakes"] = {idx = 12, max = 2},
        ["transmission"] = {idx = 13, max = 2},
        ["suspension"] = {idx = 15, max = 3},
        ["armor"] = {idx = 16, max = 4},
        ["turbo"] = {idx = 18, max = 1},
    }

    local function GetLevel(name, value)
        if (value > _mods[name].max) then
            return _mods[name].max
        elseif (value < 0) then
            return 0
        end

        return value or 0
    end

    for name, level in pairs(mods) do
        if (_mods[name]) then
            local _level = GetLevel(name, level)
            SetVehicleModKit(veh, 0)

            if (name == "turbo") then
                ToggleVehicleMod(veh, _mods[name].idx, _level)
            else
                SetVehicleMod(veh, _mods[name].idx, _level, false)
            end
        end
    end
end

--[[
    vehData = {
        pos
        model
        heading
        mods
        plate
        isNetwork
        netMissionEntity
    }
    options = {
        seat = -1, -- -1 = driver, 0 = passenger, 1 = back left, 2 = back right
        engineOn = false, -- Default false, set to true to override
        fuel = 100.0, -- Will default be 100.0, set to any other value to override
        dirtLevel = 0.0, -- Will default be 0.0, set to any other value to override
        owner = false, -- Default false (This is for qb-vehiclekeys), set to true to override´
        colors = {1, 1}, -- Primary, secondary
    }
]]
function Functions.SpawnVehicle(vehData, options)
    local hasLoaded = Functions.LoadModel(vehData.model)

    if (not hasLoaded) then return nil, {msg = "Could not load model", type = "error"} end

    local veh = CreateVehicle(vehData.model, vehData.pos.x, vehData.pos.y, vehData.pos.z, vehData.pos.h or vehData.pos.w or vehData.heading or 0.0, vehData.isNetwork or true, vehData.netMissionEntity or false)
    SetModelAsNoLongerNeeded(vehData.model)

    if (vehData.plate) then
        SetVehicleNumberPlateText(veh, vehData.plate)
    end

    if (vehData.mods) then
        Functions.SetVehicleMods(veh, vehData.mods)
    end

    if (options and options.seat) then
        SetPedIntoVehicle(PlayerPedId(), veh, options.seat)
    end

    if (options and options.colors) then
        SetVehicleColours(veh, options.colors[1] or 0, options.colors[2] or 0)
    end

    SetVehicleFuelLevel(veh, options and options.fuel or 100.0)
    SetVehicleDirtLevel(veh, options and options.dirtLevel or 0.0)
    SetVehicleEngineOn(veh, options and options.engineOn or false, true, false)

    if (Functions.GetFramework() == "QBCore") then
        if (options and (options.owner == true)) then
            TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        end
    end

    return veh, {msg = "Vehicle spawned", type = "success"}
end

function Functions.AddTargetEntity(entity, passed)
    if (Config.Target == "qb-target") then
        exports["qb-target"]:AddTargetEntity(entity, {
            options = passed.options,
            distance = passed.distance or 2.0
        })
    elseif (Config.Target == "ox_target") then
        Functions.RemoveTargetEntity(entity) -- You need to remove and re-add the entity if you want to update the options
        exports["ox_target"]:addLocalEntity(entity, passed.options)
    else
        Functions.Debug("You are using an unsupported target script, please use either qb-target or ox_target. Alternatively you can add your own target script.", true)
    end
end

function Functions.RemoveTargetEntity(entity)
    if (Config.Target == "qb-target") then
        exports["qb-target"]:RemoveTargetEntity(entity)
    elseif (Config.Target == "ox_target") then
        exports["ox_target"]:removeLocalEntity(entity)
    else
        Functions.Debug("You are using an unsupported target script, please use either qb-target or ox_target. Alternatively you can add your own target script.", true)
    end
end

function Functions.GetPlayerDetails(identifier)
    return Functions.Callback("zyke_lib:FetchPlayerDetails", false, {identifier = identifier or Functions.GetIdentifier()})
end

-- If you server already reflects and caches client side based on server side jobs, you could switch this out for a more performant version
function Functions.GetPlayersOnJob(job, onDuty)
    local p = promise.new()
    Functions.Callback("zyke_lib:GetPlayersOnJob", function(res)
        p:resolve(res)
    end, job, onDuty)

    return Citizen.Await(p)
end

-- Text entry is the menu top left
function Functions.RegisterTextEntry(name, msg)
    local prefix = GetInvokingResource() .. ":"

    AddTextEntry(prefix .. name, msg)
end

function Functions.DisplayTextEntry(name)
    local prefix = GetInvokingResource() .. ":"

    BeginTextCommandDisplayHelp(prefix .. name)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end

function Functions.HasPermission(perm)
    return Functions.Callback("zyke_lib:HasPermission", false, perm)
end

function Functions.GetPlayersInArea(coords, maxDistance)
    if (Config.Framework == "QBCore") then
        return QBCore.Functions.GetPlayersInArea(coords, maxDistance)
    elseif (Config.Framework == "ESX") then
        return ESX.Game.GetPlayersInArea(coords, maxDistance) -- Not tested (Not in use for any active releases yet)
    end
end

function Functions.GetVehiclesInArea(coords, maxDistance)
    if (Config.Framework == "QBCore") then
        return QBCore.Functions.SpawnClear(coords, maxDistance)
    elseif (Config.Framework == "ESX") then
        return ESX.Game.GetVehiclesInArea(coords, maxDistance) -- Not tested (Not in use for any active releases yet)
    end
end

function Functions.GetVehicles()
    return GetGamePool('CVehicle')
end

function Functions.GetVehicleByPlate(plate)
    local vehicles = Functions.GetVehicles()

    for _, vehicle in ipairs(vehicles) do
        if (GetVehicleNumberPlateText(vehicle) == plate) then
            return vehicle
        end
    end

    return nil
end

function Functions.GetClosestVehicle(pos, vehicles)
    pos = pos == nil and GetEntityCoords(PlayerPedId()) or pos -- Use passed in position or the player's position
    vehicles = vehicles == nil and Functions.GetVehicles() or vehicles -- Use passed in vehicles or all vehicles

    local closestEntity = nil
    local closestPos = nil
    for _, entity in pairs(vehicles) do
        local vehPos = GetEntityCoords(entity)
        local dst = #(pos - vehPos)

        if ((closestPos == nil) or (dst < closestPos)) then
            closestEntity = entity
            closestPos = dst
        end
    end

    return closestEntity, closestPos
end

function Functions.FlickerEntity(entity, times)
    for i = 255, 204, -2 do
        SetEntityAlpha(entity, i, false)
        Wait(2)
    end

    while times > 0 do
        for alpha = 204, 51, -2 do
            SetEntityAlpha(entity, alpha, false)
            Wait(2)
        end

        for alpha = 51, 204, 2 do
            SetEntityAlpha(entity, alpha, false)
            Wait(2)
        end

        times = times - 1
    end

    for i = 204, 0, -2 do
        SetEntityAlpha(entity, i, false)
        Wait(2)
    end

    return true
end

function Functions.Copy(text)
    SendNUIMessage({
        event = "copy",
        text = text,
    })

    return true
end

function Functions.IconForVehicleClass(class)
    if (class == nil) then return "car" end

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
        "boat", -- Boats
        "helicopter", -- Helicopters
        "plane", -- Planes
        "car", -- Service
        "car", -- Emergency
        "car", -- Military
        "car", -- Commercial
        "car", -- Trains
        "car" -- Open Wheel
    }

    return icons[class + 1] or "car"
end

-- pos = vector3 | table (if coord)
-- entity = entityId (if entity)
-- sprite = id (int)
-- display = id (int)
-- scale = number
-- color = id (int)
-- shortRange = state (boolean)
-- name = blip name (string)

local blips = {}
function Functions.AddBlip(details)
    local blip

    if (details.type == "coord") then
        blip = AddBlipForCoord(details.pos.x, details.pos.y, details.pos.z)
    elseif (details.type == "entity") then
        blip = AddBlipForEntity(details.entity)
    end

    if (not blip) then Functions.Debug("No type was specified in " .. GetInvokingResource(), Config.Debug) return nil end

    if (details.sprite ~= nil) then
        SetBlipSprite(blip, details.sprite)
    end

    if (details.display ~= nil) then
        SetBlipDisplay(blip, details.display)
    end

    if (details.scale ~= nil) then
        SetBlipScale(blip, details.scale)
    end

    if (details.color ~= nil) then
        SetBlipColour(blip, details.color)
    end

    if (details.shortRange ~= nil) then
        SetBlipAsShortRange(blip, details.shortRange)
    end

    if (details.name ~= nil) then
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(details.name)
        EndTextCommandSetBlipName(blip)
    end

    local invoker = GetInvokingResource()
    if (blips[invoker] == nil) then blips[invoker] = {} end

    table.insert(blips[invoker], blip)

    return blip
end

function Functions.RemoveBlip(blipId)
    local invoker = GetInvokingResource()
    if (blips[invoker]) then
        for idx, _blipId in pairs(blips[invoker]) do
            if (blipId == _blipId) then
                RemoveBlip(blipId)
                table.remove(blips[invoker], idx)
            end
        end

        if (#blips[invoker] == 0) then
            blips[invoker] = nil
        end
    end
end

-- Clear up blips as they won't be removed when restarting the script that invoked the blip creation function
AddEventHandler("onResourceStop", function(resourceName)
    if (blips[resourceName] ~= nil) then
        for _, blipId in pairs(blips[resourceName]) do
            RemoveBlip(blipId)
        end

        blips[resourceName] = nil
    end
end)

    return Citizen.Await(p)
end

function Fetch()
    return Functions
end

exports("Fetch", Fetch)