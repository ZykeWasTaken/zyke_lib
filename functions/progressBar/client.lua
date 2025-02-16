Functions.progressBar = {}

---@class ProgressBarDisableControls
---@field disableMovement boolean?
---@field disableCarMovement boolean?
---@field disableMouse boolean?
---@field disableCombat boolean?

---@class ProgressBarAnimation
---@field type "anim" | "scenario"
---@field animDict string
---@field anim string
---@field flag integer

---@class ProgressBarData
---@field name string
---@field label string
---@field duration integer
---@field useWhileDead boolean?
---@field canCancel boolean?
---@field disableControls table?
---@field animation ProgressBarAnimation?
---@field prop table? @Unused within our resources
---@field propTwo table? @Unused within our resources
---@field onFinish function?
---@field onCancel function?
---@field allowSwimming? boolean

---@param data ProgressBarData
---@return boolean @If finished
function Functions.progressBar.start(data)
    local success = false

    local state = lib.progressBar({
        duration = data.duration,
        label = data.label,
        useWhileDead = data.useWhileDead,
        canCancel = data.canCancel,
        allowSwimming = data.allowSwimming,
        anim = {
            dict = data?.animation?.animDict,
            clip = data?.animation?.anim,
            flag = data?.animation?.flag or 49,
        }
    })

    success = state
    if (state == true) then
        if (data.onFinish) then
            data.onFinish()
        end
    else
        if (data.onCancel) then
            data.onCancel()
        end
    end

    return success
end

---@return boolean
function Functions.progressBar.active()
    return lib.progressActive()
end

function Functions.progressBar.cancel()
    return lib.cancelProgress()
end

return Functions.progressBar