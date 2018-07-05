local skynet = require "skynet"
local tool = require "tool"
local faci = require "faci.module"
local runconf = require(skynet.getenv("runconfig"))

local module, static = faci.get_module("Scene")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

local libsetup = require "libsetup"
local aoi = require "scene.aoi_ex"

local Monster = require "scene.entity.monster"
local NPC = require "scene.entity.npc"
local entity_type = require "scene.entity.entity_type"

function event.start()
    local scene_id = env.id 
    log.debug("scene_id: " .. scene_id)
    local scene_conf = libsetup.scene[scene_id]
    assert(scene_conf)

    aoi.init(scene_conf.width, scene_conf.height)

    for _, v in pairs(scene_conf.npcs or {}) do
        local o = {x=0, y=0}
        local obj = NPC.new(o)
        aoi.enter(obj)
    end

    for _, v in pairs(scene_conf.monsters or {}) do
        local o = {x=0, y=0}
        local obj = Monster.new(o)
        aoi.enter(obj)
    end
    log.debug("start scene_id: " .. scene_id .. " success.")
end


function event.enter_aoi_scene(sobj, tobj)
    log.debug("=== enter_aoi_scene ===")
    if tobj.type == entity_type.Player then
        static.send_aoilist_msg(tobj, {sobj})
    end
end

function event.exit_aoi_scene(sobj, tobj)
    log.debug("=== exit_aoi_scene ===")
    if tobj.type == entity_type.Player then
        static.send_aoilist_msg(tobj, sobj.objid)
    end
end

function event.update_aoi_scene(sobj, tobj)
    log.debug("=== update_aoi_scene ===")
    if tobj.type == entity_type.Player then
        static.send_aoilist_msg(tobj, {sobj})
    end
end


