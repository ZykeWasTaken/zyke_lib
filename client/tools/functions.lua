function Tools.DrawPolyZone()
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
            active = false
        end}
    }

    for idx, key in pairs(keys) do
        local _func = key.func
        keys[idx] = Functions.GetKey(key.key)
        keys[idx].func = _func
    end

    while (active) do
        local hit, coords = RaycastFromScreen()

        if (hit) then
            -- Drawing what you're looking at
            DrawSphere(coords.x, coords.y, coords.z, 0.1, 0, 255, 0, 0.5)
            DrawLine(coords.x, coords.y, coords.z - 20.0, coords.x, coords.y, coords.z + 50.0, 0, 255, 0, 1.0)

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

    if (polyzone) then
        polyzone:destroy()
    end

    -- Formatting and copying
    local str = ""
    for _, coords in pairs(vectors) do
        str = str .. coords .. ",\n"
    end

    str = str:sub(1, -3)
    Functions.Copy(str)

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