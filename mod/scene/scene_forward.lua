local skynet = require "skynet"
local tool = require "tool"
local faci = require "faci.module"
local aoi = require "scene.aoi"

local runconf = require(skynet.getenv("runconfig"))

local module, static = faci.get_module("Scene")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event



function dispatch.MsgMove(playerid, msg)
    local player = static.get_player(playerid)
    if not player then
        return
    end

    player.x = msg.x
    player.y = msg.y
    player.direct_x = msg.directX
    player.direct_y = msg.directY 

    local obj_list = aoi.update(player)
    static.send_aoilist_msg(player, obj_list)
end

function dispatch.MsgAtk(playerid, msg)
    local player = static.get_player(playerid)
    if not player then
        return
    end

    local obj_list = aoi.update(player)
    static.send_aoilist_msg(player, obj_list)
end



