local skynet = require "skynet"
local tool = require "tool"
local faci = require "faci.module"
local runconf = require(skynet.getenv("runconfig"))

local module, static = faci.get_module("Scene")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

local libsetup = require "libsetup"

local function check_scene_id(scene_id)
    local scene_conf = libsetup.scene
    if scene_conf[scene_id] then
        return true
    end
    return false
end

function forward.MsgEnter(player, msg)
    local scene_id = msg.SceneId
    if not check_scene_id(scene_id) then
        msg.Result = 101 -- scene_id not exsit
        return msg
    end

    local isok = static.enter_scene(player, scene_id)
    if not isok then
        msg.Result = 102
    end

    msg.Result = 0
    return msg
end

function forward.MsgLeave(player, msg)
    local isok = static.leave_scene(player)
    if not isok then
        msg.Result = 103
    end
    msg.Result = 0
    return msg
end



