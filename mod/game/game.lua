local skynet = require "skynet"
local protopack = require "protopack"
local libsocket = require "libsocket"

local faci = require "faci.module"
local module = faci.get_module("Game")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event



env.players = env.players or {}
env.fds = env.fds or {}

function env.get_player(playerid)
    return env.players[playerid]
end

function env.get_playerdata(playerid)
    return env.players[playerid].data
end

--广播功能
function dispatch.send2client(playerid, msg)
	local player = env.players[playerid]
	if not player then
		return
	end
	
    player:send(msg)
end

function dispatch.send2client2(playerids,  msg)

    local cmd = msg._cmd
    local check = msg._check

    msg._cmd = nil
    msg._check = nil

    for playerid  in pairs(playerids) do
        local player = env.players[playerid]
        if player then
            player:send(msg)
        end
    end
end

function dispatch.broadcast2client(msg)
	for playerid, player in pairs(env.players) do
		dispatch.send2client(playerid, msg)
	end
end

function dispatch.fire_event(playerid, eventname, ...)
    local player = env.players[playerid]
    if not player then
        return
    end
    
    faci.fire_event(eventname, player, ...)
end

function event.start()
end

function event.exit()
	--踢掉玩家
	for playerid, player in pairs(env.players) do
        player:save_all_data()
	end
end


