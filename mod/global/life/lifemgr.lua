local skynet = require "skynet"
local log = require "log"
local libcenter = require "libcenter"

local faci = require "faci.module"
local module, static = faci.get_module("lifemgr")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

--����ս��Ϸlife
local MAX_PLAYER = 10

------------------------
--mgr
local room_mgr = {
	--[id] = ����
}
local next_id = 0

--����0ʧ�� >=1 ����id
function dispatch.create()
	next_id = next_id + 1
	room_mgr[next_id] = 0
	return next_id
end

function dispatch.delete(id)
	room_mgr[id] = nil
end


--�����������ӳ٣������ϸ����ƣ�ֻ���Ƽ�����
--����roomid �� 0��Ҫ������
function dispatch.recommend()
	--���Ż�Ϊ��ȡ�����б������ѭ��
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