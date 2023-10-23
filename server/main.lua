CreateThread(function()
    while (true) do
        GlobalState:set("OsTime", os.time(), true)
        Wait(1000)
    end
end)