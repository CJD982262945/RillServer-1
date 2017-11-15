local skynet = require "skynet"
local log = require "log"

local libcenter = require "libcenter"
local liblife = require "liblife"
local tool = require "tool"
local Player = require "game.player"
local runconf = require(skynet.getenv("runconfig"))
local node = skynet.getenv("nodename")

local faci = require "faci.module"
local module = faci.get_module("life")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event


--进入房间
function forward.enter_room(player, msg)
	--msg = {id=1,2,3}
	player.life = player.life or {}
	if player.life.room_id then
		skynet.error("enter room fail,already in room")
		msg.result = 1
		return msg
	end

	local data = {
		game = skynet.self(),
		node = node,
	}
	local ret, id = liblife.enter(player.uid, data)
	if ret then
		msg.result = 0
		player.life.room_id = id
		player.romote.life = liblife.get_forward(id)
	else
		msg.result = 1
	end
	return msg
end

--离开房间
function forward.leave_room(player, msg)
	dispatch.leave_room(player)
	return
end

--离开房间
function dispatch.leave_room(player)
	if not player.life then
		return
	end
	
	local id = player.life.room_id
	if not id then
		return
	end
	
	if liblife.leave(id, player.uid) then
		player.romote.life = nil
		player.life = nil
	end
end

--离开
function event.logout(player)
	dispatch.leave_room(player)
end