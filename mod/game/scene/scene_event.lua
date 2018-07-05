local skynet = require "skynet"
local tool = require "tool"
local faci = require "faci.module"
local runconf = require(skynet.getenv("runconfig"))

local module, static = faci.get_module("Scene")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

function event.login(player)
    local scene_id = 1
    static.enter_scene(player, scene_id)
end

function event.logout(player)
    static.leave_scene(player)
end



