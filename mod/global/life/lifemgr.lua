do return end

local skynet = require "skynet"
local log = require "log"
local env = require "env"
local libcenter = require "libcenter"

env.dispatch.lifemgr = env.dispatch.lifemgr or {}
env.forward.lifemgr = env.forward.lifemgr or {}
local D = env.dispatch.lifemgr
local F = env.forward.lifemgr
--����ս��Ϸlife
local MAX_PLAYER = 10

------------------------
--mgr
local room_mgr = {
	--[id] = ����
}
local next_id = 0

--����0ʧ�� >=1 ����id
function D.create()
	next_id = next_id + 1
	room_mgr[next_id] = 0
	return next_id
end

function D.delete(id)
	room_mgr[id] = nil
end


--�����������ӳ٣������ϸ����ƣ�ֻ���Ƽ�����
--����roomid �� 0��Ҫ������
function D.recommend()
	--���Ż�Ϊ��ȡ�����б������ѭ��
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