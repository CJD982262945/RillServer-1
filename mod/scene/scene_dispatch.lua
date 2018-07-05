local skynet = require "skynet"
local tool = require "tool"
local faci = require "faci.module"
local runconf = require(skynet.getenv("runconfig"))

local module, static = faci.get_module("Scene")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event
local nodename = skynet.getenv("nodename")

local Player = require "scene.entity.player"

function dispatch.enter_scene(playerid, data)
   log.debug("===enter_scene=== playerid: " .. playerid .. tool.dump(data))
     
   local player = Player.new(data)
   static.add_player(playerid, player)

   return true
end

function dispatch.leave_scene(playerid)
   log.debug("===leave_scene=== playerid: " .. playerid)
   static.remove_player(playerid)

   return true
end


