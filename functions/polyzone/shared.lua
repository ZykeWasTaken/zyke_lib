-- Making the default PolyZone functions available to the server-side for more validation
-- A few (or to come) custom additions to help make development easier too
-- Most logic straight taken from https://github.com/mkafrin/PolyZone, however, re-written for cleaner structure

-- TODO: Add a grid division check, as seen in the PolyZone resource

---@class PolyZone
---@field gridCellWidth number
---@field gridCellHeight number
---@field min vector2
---@field minZ? number
---@field maxZ? number
---@field points vector2[]

---@class PolyZoneInput
---@field minZ number
---@field maxZ number
---@field points vector2[]

Functions.polyzone = {}

local gridDivisions = 30 -- Never used anything other than the default

---@param cellX number
---@param cellY number
---@param poly table
local function getGridCellPoints(cellX, cellY, poly)
    local x = cellX * poly.gridCellWidth + poly.min.x
    local y = cellY * poly.gridCellHeight + poly.min.y

    return {
        vector2(x, y),
        vector2(x + poly.gridCellWidth, y),
        vector2(x + poly.gridCellWidth, y + poly.gridCellHeight),
        vector2(x, y + poly.gridCellHeight),
        vector2(x, y)
    }
end

local function isLeft(p0, p1, p2)
    local p0x = p0.x
    local p0y = p0.y

    return ((p1.x - p0x) * (p2.y - p0y)) - ((p2.x - p0x) * (p1.y - p0y))
end

local function getWindingNumberForPoint(p0, p1, p2)
    local p2y = p2.y

    if (p0.y <= p2y) then
        if (p1.y > p2y) then
            if (isLeft(p0, p1, p2) > 0) then
                return 1
            end
        end
    else
        if (p1.y <= p2y) then
            if (isLeft(p0, p1, p2) < 0) then
                return -1
            end
        end
    end

    return 0
end

-- Winding number algorithm
---@param point vector2 | Vector2Table
---@param points (vector2 | Vector2Table)[]
local function getInsideUsingWinding(point, points)
    local num = 0

    for i = 1, #points - 1 do
        num = num + getWindingNumberForPoint(points[i], points[i + 1], point)
    end

    num = num + getWindingNumberForPoint(points[#points], points[1], point)

    return num ~= 0
end

---@param pos vector3 | Vector3Table
---@param polyValues PolyZoneInput
function Functions.polyzone.isInside(pos, polyValues)
    local minX, minY = math.maxinteger, math.maxinteger
    local maxX, maxY = math.mininteger, math.mininteger
    for _, p in ipairs(polyValues.points) do
        minX = math.min(minX, p.x)
        minY = math.min(minY, p.y)
        maxX = math.max(maxX, p.x)
        maxY = math.max(maxY, p.y)
    end

    local min, max = vec2(minX, minY), vec2(maxX, maxY)
    local size = max - min

    ---@type PolyZone
    local poly = {
        gridCellWidth = size.x / gridDivisions,
        gridCellHeight = size.y / gridDivisions,
        min = min,
        minZ = polyValues.minZ or nil,
        maxZ = polyValues.maxZ or nil,
        points = polyValues.points
    }

    -- Perform a basic bounding box check
    if (
        pos.x < minX or pos.x > max.x or
        pos.y < minY or pos.y > max.y
    ) then
        return false
    end

    -- Make sure you are within the height of the polyzone
    if (
        (poly.minZ and pos.z < poly.minZ) or
        (poly.maxZ and pos.z > poly.maxZ)
    ) then
        return false
    end

    return getInsideUsingWinding(pos, poly.points)
end

-- Gives a rough idea, not reliable in all scenarios
---@param points (vector2 | Vector2Table)[]
---@return vector2
function Functions.polyzone.getMiddle(points)
    local x, y = 0, 0

    for i = 1, #points do
        x += points[i].x
        y += points[i].y
    end

    return vec2(x / #points, y / #points)
end

return Functions.polyzone