
local skynet = require "skynet"
local cluster = require "skynet.cluster"

local faci = require "faci.module"
local module = faci.get_module("Login")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event


function module.watch(acm)
	--统计在线人数
	local logined = 0		--成功登陆
	local logining = 0		--登陆流程
	for i, v in pairs(env.users) do
		if v.game then
			logined = logined + 1
		else
			logining = logining + 1
		end
	end
	local ret = {logined = logined, logining = logining}
	--总统计
	acm.logined = acm.logined and acm.logined + logined or logined
	acm.logining = acm.logining and acm.logining + logining or logining
	return ret, acm
end
