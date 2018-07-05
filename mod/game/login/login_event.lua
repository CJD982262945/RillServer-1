local skynet = require "skynet"
local libdbproxy = require "libdbproxy"
local tool = require "tool"
local Player = require "game.player.player"
local runconf = require(skynet.getenv("runconfig"))

local faci = require "faci.module"
local module = faci.get_module("Login")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event


function event.login(player)
    local name = player.data.baseinfo.name or ""
	log.info("event.login, name: " .. name)
end

function event.logout(player)
    local name = player.data.baseinfo.name or ""
	log.info("event.logout, name: " .. name)
end


