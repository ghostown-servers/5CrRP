local ox_core = exports.ox_core
local CPlayer = {}
local PlayerExports = {}
setmetatable(PlayerExports, {
    __index = function(_, index)
        PlayerExports = Ox.PlayerExports()
        return PlayerExports[index]
    end
})

function CPlayer:__index(index, ...)
    local method = CPlayer[index]

    if method then
        return function(...)
            return method(self, ...)
        end
    end

    local export = PlayerExports[index]

    if export then
        return function(...)
            return ox_core:CPlayer(index, ...)
        end
    end

    AddEventHandler(('ox:player:%s'):format(index), function(value)
        if GetInvokingResource() == 'ox_core' and source == '' then
            self[index] = value
        end
    end)

    local value = self.get(index)

    if value then
        self[index] = value
        return value
    end
end

function CPlayer:getPed()
    return cache.ped
end

function CPlayer:getCoords(update)
    if update or not self.coords then
        self.coords = GetEntityCoords(cache.ped)
    end

    return self.coords
end

function CPlayer:hasGroup(filter)
    local type = type(filter)

    if type == 'string' then
        local grade = self.groups[filter]

        if grade then
            return filter, grade
        end
    elseif type == 'table' then
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            for name, grade in pairs(filter) do
                local playerGrade = self.groups[name]

                if playerGrade and grade <= playerGrade then
                    return name, playerGrade
                end
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                local name = filter[i]
                local grade = self.groups[name]

                if grade then
                    return name, grade
                end
            end
        end
    end
end

player = Ox.GetPlayerData()

if player then
    player = setmetatable(player, CPlayer)
end

local function registerNetEvent(event, fn)
    RegisterNetEvent(event, function(...)
        if source ~= '' then fn(...) end
    end)
end

AddEventHandler('ox:playerLoaded', function(data)
    if not player then
        player = setmetatable(data, CPlayer)
    end
end)

registerNetEvent('ox:setGroup', function(name, grade)
    player.groups[name] = grade
end)

AddEventHandler('ox:playerLogout', function()
    player = nil
end)
