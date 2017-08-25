do return end

local skynet = require "skynet"
local log = require "log"
local env = require "env"
local libcenter = require "libcenter"

env.dispatch.lifemgr = env.dispatch.lifemgr or {}
env.forward.lifemgr = env.forward.lifemgr or {}
local D = env.dispatch.lifemgr
local F = env.forward.lifemgr
--大作战游戏life
local MAX_PLAYER = 10

------------------------
--mgr
local room_mgr = {
	--[id] = 人数
}
local next_id = 0

--返回0失败 >=1 房间id
function D.create()
	next_id = next_id + 1
	room_mgr[next_id] = 0
	return next_id
end

function D.delete(id)
	room_mgr[id] = nil
end


--由于有网络延迟，并非严格限制，只是推荐进入
--返回roomid 或 0（要创建）
function D.recommend()
	--可优化为读取缓存列表而不是循环
	for i, v in pairs(room_mgr) do
		if v < MAX_PLAYER then
			return i
		end
	end
	return 0
end

function D.addplayer(id)
	room_mgr[id] = room_mgr[id] + 1
	return room_mgr[id]
end

function D.leave(id)
	room_mgr[id] = room_mgr[id] - 1
	return room_mgr[id]
end