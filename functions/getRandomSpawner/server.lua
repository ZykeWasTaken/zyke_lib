-- Returns a random valid player that can act as a spawner for entities
-- Validates player loaded state, routing bucket, and distance to spawn position

-- We make sure that we have at least "z:hasLoaded" as true as the state,
-- as that is set when a player has finished loading and can spawn entities
-- If we fail to wait for this, a player can "ghost" spawn entities that will cause
-- various issues with existing whilst not at the same time

---@param spawnPos? vector3 | Vector3Table | Vector4Table @ Required when maxDst is provided, to compare
---@param maxDst? number @ Maximum distance to spawn position, for certain actions you must be under the entity "render" limit at 424
---@param desiredRoutingBucket? integer @ The routing bucket the spawner should be in, since you can't spawn entities in a different routing bucket
---@return PlayerId | nil
function Functions.getRandomSpawner(spawnPos, maxDst, desiredRoutingBucket)
    if (spawnPos) then spawnPos = vec3(spawnPos.x, spawnPos.y, spawnPos.z) end

    ---@type integer[]
    local players = Functions.getPlayers()
    local count = #players

    -- Partial Fisher-Yates shuffle
	-- Pick a random player, test it, and swap it out if invalid
    for i = count, 1, -1 do
        local j = math.random(1, i)
        local v = players[j]
        players[j] = players[i]

        if (Player(v).state["z:hasLoaded"] == true) then
            if (not desiredRoutingBucket or GetPlayerRoutingBucket(v) == desiredRoutingBucket) then
                if (not maxDst or #(GetEntityCoords(GetPlayerPed(v)) - spawnPos) < maxDst) then
                    return v
                end
            end
        end
    end

    return nil
end

return Functions.getRandomSpawner
