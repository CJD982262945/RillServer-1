local aoi = require "scene.aoi"
local faci = require "faci.module"

local aoi_ex = {}

function aoi_ex.init(width, height, maxdst)
    aoi.init(width, height, maxdst)
end

local function enterfunc(sobj, tobj)
    faci.fire_event("enter_aoi_scene", sobj, tobj)
end

local function exitfunc(sobj, tobj)
    faci.fire_event("exit_aoi_scene", sobj, tobj)
end


local function updatefunc(sobj, tobj)
    faci.fire_event("update_aoi_scene", sobj, tobj)
end

function aoi_ex.enter(obj)
    return aoi.enter(obj, enterfunc)
end

function aoi_ex.update(obj)
    return aoi.update(obj, updatefunc, enterfunc, exitfunc)
end

function aoi_ex.remove(obj)
    return aoi.remove(obj, exitfunc)
end

return aoi_ex

