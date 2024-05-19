local keys = {
    ["V"] = {keyCode = 0, name = "~INPUT_NEXT_CAMERA~"},
    ["S"] = {keyCode = 8, name = "~INPUT_SCRIPTED_FLY_UD~"},
    ["D"] = {keyCode = 9, name = "~INPUT_SCRIPTED_FLY_LR~"},
    ["PAGEUP"] = {keyCode = 10, name = "~INPUT_SCRIPTED_FLY_ZUP~"},
    ["PAGEDOWN"] = {keyCode = 11, name = "~INPUT_SCRIPTED_FLY_ZDOWN~"},
    ["SCROLLDOWN"] = {keyCode = 14, name = "~INPUT_WEAPON_WHEEL_NEXT~"},
    ["SCROLLUP"] = {keyCode = 15, name = "~INPUT_WEAPON_WHEEL_PREV~"},
    ["ENTER"] = {keyCode = 201, name = "~INPUT_FRONTEND_ACCEPT~"},
    ["LEFTALT"] = {keyCode = 19, name = "~INPUT_CHARACTER_WHEE~"},
    ["Z"] = {keyCode = 20, name = "~INPUT_MULTIPLAYER_INFO~"},
    ["LEFTSHIFT"] = {keyCode = 21, name = "~INPUT_SPRINT~"},
    ["SPACE"] = {keyCode = 22, name = "~INPUT_JUMP~"},
    ["F"] = {keyCode = 23, name = "~INPUT_ENTER~"},
    ["LEFTMOUSE"] = {keyCode = 24, name = "~INPUT_ATTACK~"},
    ["RIGHTMOUSE"] = {keyCode = 25, name = "~INPUT_AIM~"},
    ["C"] = {keyCode = 26, name = "~INPUT_LOOK_BEHIND~"},
    ["TOP"] = {keyCode = 27, name = "~INPUT_PHONE~"},
    ["B"] = {keyCode = 29, name = "~INPUT_SPECIAL_ABILITY_SECONDARY~"},
    ["W"] = {keyCode = 32, name = "~INPUT_MOVE_UP_ONLY~"},
    ["A"] = {keyCode = 34, name = "~INPUT_MOVE_LEFT_ONLY~"},
    ["TAB"] = {keyCode = 37, name = "~INPUT_SELECT_WEAPON~"},
    ["E"] = {keyCode = 38, name = "~INPUT_PICKUP~"},
    ["["] = {keyCode = 39, name = "~INPUT_SNIPER_ZOOM~"},
    ["]"] = {keyCode = 40, name = "~INPUT_SNIPER_ZOOM_IN_ONLY~"},
    ["Q"] = {keyCode = 44, name = "~INPUT_COVER~"},
    ["R"] = {keyCode = 140, name = "~INPUT_MELEE_ATTACK_LIGHT~"},
    ["G"] = {keyCode = 47, name = "~INPUT_DETONATE~"},
    ["F9"] = {keyCode = 56, name = "~INPUT_DROP_WEAPON~"},
    ["F10"] = {keyCode = 57, name = "~INPUT_DROP_AMMO~"},
    ["RIGHTCTRL"] = {keyCode = 70, name = "~INPUT_VEH_ATTACK2~"},
    ["X"] = {keyCode = 73, name = "~INPUT_VEH_DUCK~"},
    ["H"] = {keyCode = 74, name = "~INPUT_VEH_HEADLIGHT~"},
    ["."] = {keyCode = 81, name = "~INPUT_VEH_NEXT_RADIO~"},
    [","] = {keyCode = 82, name = "~INPUT_VEH_PREV_RADIO~"},
    ["="] = {keyCode = 83, name = "~INPUT_VEH_NEXT_RADIO_TRACK~"},
    ["-"] = {keyCode = 84, name = "~INPUT_VEH_PREV_RADIO_TRACK~"},
    ["CAPS"] = {keyCode = 137, name = "~INPUT_VEH_PUSHBIKE_SPRINT~"},
    ["1"] = {keyCode = 157, name = "~INPUT_SELECT_WEAPON_UNARMED~"},
    ["2"] = {keyCode = 158, name = "~INPUT_SELECT_WEAPON_MELEE~"},
    ["6"] = {keyCode = 159, name = "INPUT_SELECT_WEAPON_HANDGUN~~"},
    ["3"] = {keyCode = 160, name = "~INPUT_SELECT_WEAPON_SHOTGUN~"},
    ["7"] = {keyCode = 161, name = "~INPUT_SELECT_WEAPON_SMG~"},
    ["8"] = {keyCode = 162, name = "~INPUT_SELECT_WEAPON_AUTO_RIFLE~"},
    ["9"] = {keyCode = 163, name = "~INPUT_SELECT_WEAPON_SNIPER~"},
    ["4"] = {keyCode = 164, name = "~INPUT_SELECT_WEAPON_HEAVY~"},
    ["5"] = {keyCode = 165, name = "~INPUT_SELECT_WEAPON_SPECIAL~"},
    ["F5"] = {keyCode = 166, name = "~INPUT_SELECT_CHARACTER_MICHAEL~"},
    ["F6"] = {keyCode = 167, name = "~INPUT_SELECT_CHARACTER_FRANKLIN~"},
    ["F7"] = {keyCode = 168, name = "~INPUT_SELECT_CHARACTER_TREVOR~"},
    ["F8"] = {keyCode = 169, name = "~INPUT_SELECT_CHARACTER_MULTIPLAYER~"},
    ["F3"] = {keyCode = 170, name = "~INPUT_SAVE_REPLAY_CLIP~"},
    ["UP"] = {keyCode = 172, name = "~INPUT_CELLPHONE_UP~"},
    ["DOWN"] = {keyCode = 173, name = "~INPUT_CELLPHONE_DOWN~"},
    ["LEFT"] = {keyCode = 174, name = "~INPUT_CELLPHONE_LEFT~"},
    ["RIGHT"] = {keyCode = 175, name = "~INPUT_CELLPHONE_RIGHT~"},
    ["CANCEL"] = {keyCode = 177, name = "~INPUT_CELLPHONE_CANCEL~"}, -- BACKSPACE / ESC / RIGHT MOUSE BUTTON
    ["DELETE"] = {keyCode = 178, name = "~INPUT_CELLPHONE_OPTION~"},
    ["L"] = {keyCode = 182, name = "~INPUT_CELLPHONE_CAMERA_FOCUS_LOCK~"},
    ["BACKSPACE"] = {keyCode = 202, name = "~INPUT_FRONTEND_CANCEL~"},
    ["HOME"] = {keyCode = 213, name = "~INPUT_FRONTEND_SOCIAL_CLUB_SECONDARY~"},
    ["~"] = {keyCode = 243, name = "~INPUT_ENTER_CHEAT_CODE~"},
    ["M"] = {keyCode = 244, name = "~INPUT_INTERACTION_MENU~"},
    ["T"] = {keyCode = 245, name = "~INPUT_MP_TEXT_CHAT_ALL~"},
    ["Y"] = {keyCode = 246, name = "~INPUT_MP_TEXT_CHAT_TEAM~"},
    ["N"] = {keyCode = 249, name = "~INPUT_PUSH_TO_TALK~"},
    ["F1"] = {keyCode = 288, name = "~INPUT_REPLAY_START_STOP_RECORDING~"},
    ["F2"] = {keyCode = 289, name = "~INPUT_REPLAY_START_STOP_RECORDING_SECONDARY~"},
    ["U"] = {keyCode = 303, name = "INPUT_REPLAY_SCREENSHOT~~"},
    ["K"] = {keyCode = 311, name = "~INPUT_REPLAY_SHOWHOTKEY~"},
    ["ESC"] = {keyCode = 322, name = "~INPUT_REPLAY_TOGGLE_TIMELINE~"},
    ["LEFTCTRL"] = {keyCode = 326, name = "~INPUT_DUCK~"},
}

function Functions.GetKey(key)
    local keyData = {}

    if (type(key) == "string") then
        keyData = keys[key]
        if (not keyData) then Functions.Debug("Could not find key .. " .. tostring(key), Config.Debug) return nil end
    elseif (type(key) == "table") then
        local _keys = {}
        for _, keyName in pairs(key) do
            _keys[#_keys+1] = Functions.GetKey(keyName)
        end

        keyData = _keys
    else
        error("You are attempting to get a key with an invalid type.")
    end

    return keyData
end

function Functions.GetKeys()
    return keys
end