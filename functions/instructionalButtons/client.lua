Functions.instructionalButtons = {}

---@param buttons table
---@return ScaleformHandle
function Functions.instructionalButtons.register(buttons)
    local scaleform = RequestScaleformMovie("instructional_buttons")
    while (not HasScaleformMovieLoaded(scaleform)) do
        Wait(10)
    end

    BeginScaleformMovieMethod(scaleform, "CLEAR_ALL")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_CLEAR_SPACE")
    ScaleformMovieMethodAddParamInt(200)
    EndScaleformMovieMethod()

    local removedIndexes = 0
    for idx, button in pairs(buttons) do
        local key = Functions.keys.get(button.key)
        if (key) then
            -- Check if that button is pressed, if it is not pressed, go to end of loop
            if (button.activate ~= nil) then
                local keyToPress = Functions.keys.get(button.activate)
                if (keyToPress) then
                    if (not IsDisabledControlPressed(0, keyToPress.keyCode)) then
                        removedIndexes = removedIndexes + 1
                        goto endOfLoop
                    end
                else
                    error("Trying to find key that does not exist" .. button.activate)
                end
            end

            if (button.disable ~= nil) then
                -- Check if that button is pressed, if it is pressed, go to end of loop
                local keyToPress = Functions.keys.get(button.disable)
                if (keyToPress) then
                    if (IsDisabledControlPressed(0, keyToPress.keyCode)) then
                        removedIndexes = removedIndexes + 1
                        goto endOfLoop
                    end
                else
                    error("Trying to find key that does not exist" .. button.disable)
                end
            end

            BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
            ScaleformMovieMethodAddParamInt(idx - 1 - removedIndexes)

            if (type(button.key) == "string") then
                ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(2, key.keyCode, true))
            elseif (type(button.key) == "table") then
                for _idx = #key, 1, -1 do
                    local keyData = key[_idx]
                    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(2, keyData.keyCode, true))
                end
            end

            BeginTextCommandScaleformString("STRING")
            AddTextComponentSubstringKeyboardDisplay(button.label)
            EndTextCommandScaleformString()
            EndScaleformMovieMethod()

            ::endOfLoop::
        else
            error("Attempted to register an instruction with an invalid key: " .. button.key)
        end
    end

    BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND_COLOUR")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(80)
    EndScaleformMovieMethod()

    return scaleform
end

---@param scaleform ScaleformHandle
function Functions.instructionalButtons.draw(scaleform)
    DrawScaleformMovieFullscreen(scaleform, 0, 0, 0, 0, 0)
end

return Functions.instructionalButtons