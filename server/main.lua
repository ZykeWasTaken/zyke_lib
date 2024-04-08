-- Keeps track of all sessions
Sessions = {
    entities = {},
    players = {}
}

CreateThread(function()
    while (true) do
        GlobalState:set("OsTime", os.time(), true)
        Wait(1000)
    end
end)