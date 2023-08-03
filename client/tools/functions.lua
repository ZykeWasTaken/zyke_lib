function Tools.DrawPolyZone()
    local invoker = GetInvokingResource()
    local active = true
    local vectors = {}

    local minZ = GetEntityCoords(PlayerPedId())
    local maxZ = minZ + 5.0
    local polyzone
    local function generateNewPolyzone()
        if (polyzone) then
            polyzone:destroy()
        end

        if (#vectors > 0) then
            polyzone = PolyZone:Create(vectors, {
                name = "zyke_lib_drawing_zone",
                minZ = minZ,
                maxZ = maxZ,
                debugGrid = true,
            })
        end
    end

    local str
    ---@param save boolean -- true to save & copy coordinates
    local function stop(save)
        active = false

        if (polyzone) then
            polyzone:destroy()
        end

        if (save) then
            -- Formatting and copying
            str = ""
            for _, coords in pairs(vectors) do
                str = str .. coords .. ",\n"
            end

            str = str:sub(1, -3)
            Functions.Copy(str)
        end
    end

    local keys = {
        {key = "LEFTMOUSE", func = function(coords)
            local _coords = vec2(coords.x, coords.y)
            table.insert(vectors, _coords)

            generateNewPolyzone()
        end},
        {key = "RIGHTMOUSE", func = function()
            table.remove(vectors, #vectors)

            generateNewPolyzone()
        end},
        {key = "ENTER", func = function()
            stop(true)
        end},
        {key = "BACKSPACE", func = function()
            stop(false)
        end}
    }

    for idx, key in pairs(keys) do
        local _func = key.func
        keys[idx] = Functions.GetKey(key.key)
        keys[idx].func = _func
    end

    -- Register instructions
    local instructionsMsg = ""
    instructionsMsg = instructionsMsg .. "~INPUT_ATTACK~ Place Point"           -- Place point/line
    instructionsMsg = instructionsMsg .. "\n~INPUT_AIM~ Remove Last Point"      -- Remove last point/line placed
    instructionsMsg = instructionsMsg .. "\n~INPUT_FRONTEND_ACCEPT~ Save"       -- Stop the drawing & copy the coordinates
    instructionsMsg = instructionsMsg .. "\n~INPUT_CELLPHONE_CANCEL~ Cancel"    -- Stop the drawing & scrap all coordinates
    Functions.RegisterTextEntry("draw_polyzone_instructions", instructionsMsg)

    while (active) do
        local hit, coords = RaycastFromScreen()

        if (hit) then
            -- Drawing what you're looking at
            DrawSphere(coords.x, coords.y, coords.z, 0.1, 0, 255, 0, 0.5)
            DrawLine(coords.x, coords.y, coords.z - 20.0, coords.x, coords.y, coords.z + 50.0, 0, 255, 0, 1.0)
            Functions.DisplayTextEntry("draw_polyzone_instructions", invoker)

            -- Disabling attacking, so that you can use your mouse to make the points
            for _, key in pairs(keys) do
                DisableControlAction(0, key.keyCode, true)

                if (IsDisabledControlJustReleased(0, key.keyCode)) then
                    key.func(coords)
                end
            end
        end

        Wait(0)
    end

    return vectors, {str}
end

function RaycastFromScreen()
    local camera = GetGameplayCamCoord()
    local cameraRot = GetGameplayCamRot(2)
    local radiansX = math.rad(cameraRot.x)
    local radiansZ = math.rad(cameraRot.z)
    local num = math.abs(math.cos(radiansX))
    local direction = vec3(-math.sin(radiansZ) * num, math.cos(radiansZ) * num, math.sin(radiansX))
    local endPoint = camera + (direction * 1000.0)
    local _, hit, hitCoords, _, _ = GetShapeTestResult(StartShapeTestRay(camera.x, camera.y, camera.z, endPoint.x, endPoint.y, endPoint.z, -1, PlayerPedId(), 0))

    return hit, vec3(hitCoords.x, hitCoords.y, hitCoords.z)
end