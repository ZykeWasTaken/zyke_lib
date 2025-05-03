Functions.instructionalButtons = {}

---@class ButtonProps
---@field label string
---@field key string | string[]
---@field activate? string @Key to enable this option
---@field disable? string @Key to disable this option
---@field forceRender? boolean @If pressed, forcefully re-register the buttons
---@field func fun(keyCode: integer, key: string, active: string?, disable: string?)
---@field inactive? boolean @Set by isInactive
---@field isInactive fun(): boolean @Function to check if the button should be set as inactive

local keys = Functions.keys.getAll()

local scaleforms = {}
scaleforms.__index = scaleforms

---@param buttons ButtonProps[]
function scaleforms:registerButtons(buttons)
    local scaleform = RequestScaleformMovie("instructional_buttons")
    while (not HasScaleformMovieLoaded(scaleform)) do Wait(10) end

    BeginScaleformMovieMethod(scaleform, "CLEAR_ALL")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_CLEAR_SPACE")
    ScaleformMovieMethodAddParamInt(200)
    EndScaleformMovieMethod()

    local removedIndexes = 0
    for i = 1, #buttons do
        local key = Functions.keys.get(buttons[i].key)
        if (not key) then error("Attempted to register an instruction with an invalid key: " .. buttons[i].key) return end

        if (buttons[i].isInactive and buttons[i].isInactive()) then
            buttons[i].inactive = true
            removedIndexes = removedIndexes + 1
            goto continue
        else
            buttons[i].inactive = false
        end

        -- Handle activator key
        if (buttons[i].activate ~= nil) then
            local activatorKey = keys[buttons[i].activate]
            if (not activatorKey) then error("Attempted to check an activator key with an invalid key: " .. buttons[i].activate) return end

            if (not IsDisabledControlPressed(0, activatorKey.keyCode)) then
                removedIndexes = removedIndexes + 1
                goto continue
            end
        end

        -- Handle disabler key
        if (buttons[i].disable) then
            local disablerKey = keys[buttons[i].disable]
            if (not disablerKey) then error("Attempted to check a disabler key with an invalid key: " .. buttons[i].disable) return end

            if (not IsDisabledControlPressed(0, disablerKey.keyCode)) then
                removedIndexes = removedIndexes + 1
                goto continue
            end
        end

        BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(i - 1 - removedIndexes)

        if (type(buttons[i].key) == "table") then
            if (#key == 0) then error("Attempted to register an instruction with an invalid key: " .. json.encode(buttons[i].key)) return end

            for j = 1, #key do
                if (not key[j].keyCode) then error("Attempted to register an instruction with an invalid key: " .. json.encode(buttons[i].key)) return end

                ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(2, key[j].keyCode, true))
            end
        else
            ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(2, key.keyCode, true))
        end

        BeginTextCommandScaleformString("STRING")
        AddTextComponentSubstringKeyboardDisplay(buttons[i].label)
        EndTextCommandScaleformString()
        EndScaleformMovieMethod()

        ::continue::
    end

    BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND_COLOUR")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(80)
    EndScaleformMovieMethod()

    self.buttons = buttons
    self.scaleform = scaleform
end

function scaleforms:render()
    if (not self.scaleform) then error("Attempting to draw non-existent scaleform") return end

    DrawScaleformMovieFullscreen(self.scaleform, 0, 0, 0, 0, 0)
end

-- To be called in a thread
-- Disables buttons, and executes functions on presses
function scaleforms:handleButtons()
    for i = 1, #self.buttons do
        local isMulti = type(self.buttons[i].key) == "table"
        if (self.buttons[i].inactive) then goto continue end

        if (isMulti) then
            for j = 1, #self.buttons[i].key do
                local keyCode = keys[self.buttons[i].key[j]].keyCode

                DisableControlAction(0, keyCode, true)
                if (IsDisabledControlJustPressed(0, keyCode)) then
                    self.buttons[i].func(keyCode, self.buttons[i].key[j], self.buttons[i].activate, self.buttons[i].disable)
                end
            end
        else
            local keyCode = keys[self.buttons[i].key].keyCode

            DisableControlAction(0, keyCode, true)
            if (IsDisabledControlJustPressed(0, keyCode)) then
                self.buttons[i].func(keyCode, self.buttons[i].key, self.buttons[i].activate, self.buttons[i].disable)
            end
        end

        ::continue::
    end
end

function Functions.instructionalButtons.create()
    local self = setmetatable({}, scaleforms)

    self.scaleform = nil

    ---@type ButtonProps[]
    self.buttons = {}

    scaleforms[#scaleforms+1] = self

    return self
end

-------------------------------------------------- CODE BELOW IS DEPRECATED --------------------------------------------------
--- It will be kept until garages has been updated to use the new functions

---@param buttons ButtonProps[]
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