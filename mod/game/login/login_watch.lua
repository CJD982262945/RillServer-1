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

function module.watch(acm)
	--统计在线人数
	local logined = 0		--成功登陆
	for i, v in pairs(env.players) do
		logined = logined + 1
	end
	local ret = {logined = logined}
	--总统计
	acm.logined = acm.logined and acm.logined + logined or logined

	return ret, acm
end
