local skynet = require "skynet"
local cluster = require "skynet.cluster"

local faci = require "faci.module"
local module = faci.get_module("Broadcast")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

--发送
local function send(node, adress, cmd, ...)
	if node == skynet.getenv("nodename") then
		skynet.send(adress, "lua", cmd, ...)
	else 
		cluster.send(node, adress, cmd, ...)
	end
end

function dispatch.broadcast2client(msg)
	for playerid, playerid_data in pairs(env.users) do
		log.debug("center broadcast_msg send to: " .. playerid)
		dispatch.send2client(playerid, msg)
	end
end

--发送给某个client
function dispatch.send2client(playerid, msg)
	local user = env.users[playerid]
	--未登陆
	if not user then
		log.debug("center send_agent not user " .. playerid)
		return
	end
	--未绑定game
	if not user.game then
		log.debug("center send_agent not user.game " .. playerid)
		return
	end

	send(user.node, user.game, "Game.send2client", playerid, msg)
end

