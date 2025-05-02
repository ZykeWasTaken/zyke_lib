Functions.target = {}

local targets = {}

---@return integer
local function generateId()
    local id

    repeat
        id = math.random(1000000, 9999999)
    until targets[id] == nil

    return id
end

---@class TargetOption
---@field num number? @Index in menu, probably never used
---@field icon string
---@field label string
---@field canInteract? function @Returns boolean if possible to interact
---@field action? function @qb-target
---@field onSelect? function @ox_target
---@field distance number? @ox_target

---@class EntityTargetDetails
---@field distance number? @2.0 default
---@field options TargetOption[]

---@class BoxTargetDetails
---@field name string @id
---@field pos vector3
---@field length number
---@field width number
---@field minZ number
---@field maxZ number
---@field heading number
---@field debugPoly boolean
---@field options TargetOption[]
---@field distance number? @2.0 default

-- Translating and ensuring distance exists properly
---@param targetDetails EntityTargetDetails | BoxTargetDetails
local function ensureTargetDetails(targetDetails)
    if (not targetDetails.distance) then
        targetDetails.distance = 2.0
    end

    -- Adding distance and action to every option for compatibility
    for i = 1, #targetDetails.options do
        targetDetails.options[i].distance = targetDetails.distance
        targetDetails.options[i].action = targetDetails.options[i].onSelect
    end

    return targetDetails
end

---@param entity integer
---@param targetDetails EntityTargetDetails
---@return integer | nil @Id
function Functions.target.addEntity(entity, targetDetails)
    ---@type EntityTargetDetails
    ---@diagnostic disable-next-line: assign-type-mismatch
    targetDetails = ensureTargetDetails(targetDetails)

    if (Target == "OX") then
        if (targets[entity]) then
            Functions.target.remove(entity) -- Need to re-add entity, otherwise options stack
        end

        exports["ox_target"]:addLocalEntity(entity, targetDetails.options)

        targets[entity] = {type = "entity"}

        return entity
    elseif (Target == "QB") then
        exports["qb-target"]:AddTargetEntity(entity, {
            options = targetDetails.options,
            distance = targetDetails.distance
        })

        targets[entity] = {type = "entity"}

        return entity
    end

    return nil
end

---@param targetDetails BoxTargetDetails
---@return string | integer | nil @id
function Functions.target.addBox(targetDetails)
    ---@type BoxTargetDetails
    ---@diagnostic disable-next-line: assign-type-mismatch
    targetDetails = ensureTargetDetails(targetDetails)

    if (Target == "OX") then
        -- Some cursed stuff I did ages ago, not sure if this has to be revised
        local height = (targetDetails.pos.z - targetDetails.minZ) + (targetDetails.maxZ - targetDetails.pos.z)
        local size = vec3(targetDetails.width, targetDetails.length, height)
        local coords = vec3(targetDetails.pos.x, targetDetails.pos.y, (targetDetails.pos.z - (targetDetails.pos.z - targetDetails.minZ)) + (height / 2))

        local id = exports["ox_target"]:addBoxZone({
            coords = coords,
            size = size,
            rotation = targetDetails.heading,
            debug = targetDetails.debugPoly,
            options = targetDetails.options
        })

        targets[id] = {type = "zone"}

        return id
    elseif (Target == "QB") then
        local id = generateId()

        exports["qb-target"]:AddBoxZone(id, targetDetails.pos, targetDetails.length, targetDetails.width, {
            name = id,
            heading = targetDetails.heading,
            minZ = targetDetails.minZ,
            maxZ = targetDetails.maxZ,
            debugPoly = targetDetails.debugPoly
        }, {
            distance = targetDetails.distance or 2.0,
            options = targetDetails.options
        })

        targets[id] = {type = "zone"}

        return id
    end

    return nil
end

---@param id string | integer
function Functions.target.remove(id)
    local details = targets[id]
    -- if (not details) then return error(("Attempting to delete non-existent target: %s"):format(id)) end
    if (not details) then return end -- Fix this because of entities, because they might have other ids saved because of handle changing

    local zoneType = details.type
    targets[id] = nil

    if (zoneType == "entity") then
        if (Target == "OX") then return exports["ox_target"]:removeLocalEntity(id) end
        if (Target == "QB") then return exports["qb-target"]:RemoveTargetEntity(id) end
    elseif (zoneType == "zone") then
        if (Target == "OX") then return exports["ox_target"]:removeZone(id) end
        if (Target == "QB") then return exports["qb-target"]:RemoveZone(id) end
    end
end

---@param targetDetails EntityTargetDetails
function Functions.target.addModel(model, targetDetails)
    ---@type EntityTargetDetails
    ---@diagnostic disable-next-line: assign-type-mismatch
    targetDetails = ensureTargetDetails(targetDetails)

    if (Target == "OX") then
        exports["ox_target"]:addModel(model, targetDetails.options)
    elseif (Target == "QB") then
        exports["qb-target"]:AddTargetModel(model, {
            options = targetDetails.options,
            distance = targetDetails.distance
        })
    end
end

---@return boolean
function Functions.target.isTargeting()
    local key = 19

    return IsControlPressed(0, key) or IsDisabledControlPressed(0, key)
end

AddEventHandler("onResourceStop", function(resName)
    if (resName ~= ResName) then return end

    for id, details in pairs(targets) do
        Functions.target.remove(id)
    end
end)

return Functions.target