-- Sets the OsTime
CreateThread(function()
    while (true) do
        GlobalState:set("OsTime", os.time(), true)
        Wait(1000)
    end
end)

-- Keeping track of routing buckets
CreateThread(function()
    while (true) do
        local players = GetPlayers()
        for i = 1, #players do
            local bucketId = GetPlayerRoutingBucket(players[i])
            Player(players[i]).state:set("routingBucket", bucketId, true)
        end

        Wait(500)
    end
end)