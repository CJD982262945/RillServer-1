local skynet = require "skynet"
local log = require "log"
local libcenter = require "libcenter"

local faci = require "faci.module"
local module, static = faci.get_module("lifemgr")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

--大作战游戏life
local MAX_PLAYER = 10

------------------------
--mgr
local room_mgr = {
	--[id] = 人数
}
local next_id = 0

--返回0失败 >=1 房间id
function dispatch.create()
	next_id = next_id + 1
	room_mgr[next_id] = 0
	return next_id
end

function dispatch.delete(id)
	room_mgr[id] = nil
end


--由于有网络延迟，并非严格限制，只是推荐进入
--返回roomid 或 0（要创建）
function dispatch.recommend()
	--可优化为读取缓存列表而不是循环
	for i, v in pairs(room_mgr) do
		if v < MAX_PLAYER then
			return i
		end
	end
	return 0
end

function dispatch.addplayer(id)
	room_mgr[id] = room_mgr[id] + 1
	return room_mgr[id]
end

function dispatch.leave(id)
	room_mgr[id] = room_mgr[id] - 1
	return room_mgr[id]
end


function module.watch(acm)
	return room_mgr
end