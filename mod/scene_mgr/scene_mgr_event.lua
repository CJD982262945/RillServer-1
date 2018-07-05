local skynet = require "skynet"
local tool = require "tool"
local faci = require "faci.module"
local libsetup = require "libsetup"
local cluster = require "cluster"


local runconf = require(skynet.getenv("runconfig"))

local module, static = faci.get_module("SceneMgr")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

local servconf = runconf.service
local local_nodename = skynet.getenv("nodename")


function event.start()
end



