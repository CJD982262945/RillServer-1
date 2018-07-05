local skynet = require "skynet"
local tool = require "tool"
local faci = require "faci.module"
local runconf = require(skynet.getenv("runconfig"))

local module, static = faci.get_module("Scene")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event
local nodename = skynet.getenv("nodename")

local libsetup = require "libsetup"


local function build_combat_player(player)
    return {
        playerid = player.playerid,
        atk = 100,
        def = 100,
        x = 0,
        y = 0,
        node = nodename,
        game = skynet.self(),
    }
end

function static.leave_scene(player)
    local playerid = player.playerid
    local scene_name = player.romote.Scene
    local isok = skynet.call(scene_name, "lua", "Scene.leave_scene", playerid)
    if not isok then
        return false
    end 

    player.scene_id = nil
    player.romote.Scene = nil
    return true
end

function static.enter_scene(player, scene_id)
    -- 已经在某个场景，就先退出
    if player.scene_id then
        if player.scene_id == scene_id then
            log.debug("playerid: " .. player.playerid .. " have in scene, scene_id: " .. scene_id)
            return false
        end

        if not static.leave_scene(player) then
            return false
        end
    end

    local scene_name = string.format("scene%d", scene_id)
    local playerid = player.playerid
    local data = build_combat_player(player)
    local isok = skynet.call(scene_name, "lua", "Scene.enter_scene", playerid, data)
    if not isok then
        return false
    end 


    player.scene_id = scene_id
    player.romote.Scene = scene_name

    return true
end

