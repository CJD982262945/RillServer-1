local entity_type = require "scene.entity.entity_type"
local genid = require "scene.entity.genid"


local NPC = {}

NPC.__index = NPC

function NPC.new(o)
    local o = o or {}
    o.type = entity_type.NPC 
    o.objid = genid.new_id()
    o.model = "wm"
    setmetatable(o, NPC)
    return o
end

function NPC:get_obj()
    return {
        objId = self.objid,
        playerId = 0,
        name = "npc",
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

function NPC:send(cmd, msg)
end

function NPC:send2game(cmd, ...)
end

function NPC:fire_game_event(eventname, ...)
end 

return NPC
