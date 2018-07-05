local entity_type = require "scene.entity.entity_type"
local genid = require "scene.entity.genid"

local Monster = {}

Monster.__index = Monster

function Monster.new(o)
    local o = o or {}
    o.type = entity_type.Monster 
    o.objid = genid.new_id()
    o.model = "wm"
    setmetatable(o, Monster)
    return o
end

function Monster:get_obj()
    return {
        objId = self.objid,
        playerId = 0,
        name = "monster",
        type = self.type,
        hp = 100,
        maxHp = 100,
        lvl = 1,
        x = 0, 
        y = 0,
        directX = 0,
        directY = 0,
    }
end

function Monster:send(cmd, msg)
end

function Monster:send2game(cmd, ...)
end

function Monster:fire_game_event(eventname, ...)
end 

return Monster
