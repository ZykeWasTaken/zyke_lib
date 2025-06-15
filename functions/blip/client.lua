Functions.blip = {}

---@class BlipDetails
---@field type "coord" | "entity" | "radius"
---@field pos vector3 | table
---@field entity number? @Entity handle
---@field sprite number?
---@field display number?
---@field scale number?
---@field color number?
---@field shortRange boolean?
---@field name string?
---@field alpha number?

local blips = {}

---@param data BlipDetails
---@return Blip | nil
function Functions.blip.add(data)
    local blip

    if (data.type == "coord") then
        blip = AddBlipForCoord(data.pos.x, data.pos.y, data.pos.z)
    elseif (data.type == "entity") then
        blip = AddBlipForEntity(data.entity)
    elseif (data.type == "radius") then
        blip = AddBlipForRadius(data.pos.x, data.pos.y, data.pos.z, data.scale)
    end

    if (not blip) then Functions.debug.internal("No blip type was specified") return nil end

    local sprite = (data.type == "radius" and 9) or data.sprite or 1

    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, data.display or 6)
    SetBlipScale(blip, data.scale or 0.8)
    SetBlipAsShortRange(blip, data.shortRange or false)
    SetBlipAlpha(blip, data.alpha or 255)

    if (data.color ~= nil and data.color ~= -1) then
        SetBlipColour(blip, data.color)
    end

    if (data.name ~= nil) then
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.name)
        EndTextCommandSetBlipName(blip)
    end

    blips[#blips+1] = blip

    return blip
end

---@param blip Blip
function Functions.blip.remove(blip)
    for i = 1, #blips do
        if (blips[i] == blip) then
            if (DoesBlipExist(blip)) then
                RemoveBlip(blip)
            end

            table.remove(blips, i)
            return
        end
    end
end

return Functions.blip