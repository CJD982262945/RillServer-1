local entity_type = require "scene.entity.entity_type"
local genid = require "scene.entity.genid"
local skynet = require "skynet"
local cluster = require "cluster"

local local_nodename = skynet.getenv('nodename')

local Player = {}

Player.__index = Player

function Player.new(o)
    local o = o or {}
    o.type = entity_type.Player 
    o.objid = genid.new_id()
    o.model = "wm"
    setmetatable(o, Player)
    return o
end

function Player:get_obj()
    return {
        objId = self.objid,
        playerId = self.playerid,
        name = "player",
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

function Player:send(cmd, msg)
    msg._cmd = cmd
    self:send2game("Game.send2client", self.playerid, msg)
end

function Player:send2game(cmd, ...)
    if self.node == local_nodename then
        skynet.send(self.game, "lua", cmd, ...)
    else
        cluster.send(self.node, self.game, cmd, ...)
    end
end

function Player:fire_game_event(eventname, ...)
    if self.node == local_nodename then
        skynet.send(self.game, "lua", "Game.fire_event", self.playerid, eventname, ...)
    else
        cluster.send(self.node, self.game, "Game.fire_event", self.playerid, eventname, ...)
    end
end

return Player

