-- TODO: Debug warning when overwriting commands

---@param commands string[] | string
---@param fn function
---@param helperMsg? string
---@param args? table<string[]>
function Functions.registerCommand(commands, fn, helperMsg, args)
    if (type(commands) ~= "table") then commands = {commands} end

    local function getArgs()
        if (not args or #args == 0) then return {} end

        local _args = {}

        for i = 1, #args do
            _args[#_args+1] = {name = args[i][1], help = args[i][2]}
        end

        return _args
    end

    local function addSuggestion(cmd)
        local _args = getArgs()

        if (Context == "server") then
            TriggerClientEvent("chat:addSuggestion", -1, ("/%s"):format(cmd), helperMsg, _args)
        else
            TriggerEvent("chat:addSuggestion", ("/%s"):format(cmd), helperMsg, _args)
        end
    end

    for i = 1, #commands do
        RegisterCommand(commands[i], fn, false)

        addSuggestion(commands[i])
    end
end

return Functions.registerCommand