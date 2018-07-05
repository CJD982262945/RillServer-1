local skynet = require "skynet"
local tool = require "tool"
local faci = require "faci.module"
local runconf = require(skynet.getenv("runconfig"))

local module, static = faci.get_module("Scene")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event
local aoi = require "scene.aoi_ex"

env.players = env.players or {}

local function build_aoilist_msg(obj_list)
    local msg = {}
    msg.objs = {} 
    for k, v in pairs(obj_list) do
        table.insert(msg.objs, v:get_obj())
    end
    return msg
end

local function build_aoiexit_msg(objid)
    local msg = {}
    msg.objId = objid
    return msg
end

function static.send_aoilist_msg(player, obj_list)
    local msg = build_aoilist_msg(obj_list)
    player:send("Scene.MsgAOIList", msg)
end

function static.send_aoiexit_msg(player, objid)
    local msg = build_aoiexit_msg(objid)
    player:send("Scene.MsgAOIExit", msg)
end

function static.add_player(playerid, player)
    env.players[playerid] = player
    local obj_list = aoi.enter(player)
    static.send_aoilist_msg(player, obj_list)
end

function static.remove_player(playerid)
    local player = env.players[playerid]
    if not player then
        return false
    end

    aoi.remove(player)

    env.players[playerid] = nil
    static.send_aoiexit_msg(player, playerid)
end

function static.get_player(playerid)
    return env.players[playerid]
end









