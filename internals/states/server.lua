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
            local prev = Player(players[i]).state["routingBucket"]

            if (prev ~= bucketId) then
                Player(players[i]).state:set("routingBucket", bucketId, true)
            end
        end

        Wait(500)
    end
end)