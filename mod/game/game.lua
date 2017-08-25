local skynet = require "skynet"
local protopack = require "protopack"
local libsocket = require "libsocket"

local faci = require "faci.module"
local module = faci.get_module("game")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event




env.players = env.players or {}
env.fds = env.fds or {}

function env.get_player(uid)
    return env.players[uid]
end

function env.get_playerdata(uid)
    return env.players[uid].data
end

--广播功能
function dispatch.send2client(uid, msg)
	local player = env.players[uid]
	if not player then
		return
	end
	
    local cmd = msg._cmd
	local check = msg._check
	msg._cmd = nil
	msg._check = nil
	local data = protopack.pack(cmd, check, msg)
	libsocket.send(player.fd, data)
end

function dispatch.broadcast2client(msg)
	for uid, player in pairs(env.players) do
		dispatch.send2client(uid, msg)
	end
end
