local skynet = require "skynet"
local env = require "env"
local log = require "log"
local libcenter = require "libcenter"
local M = {}

function M.send_msg(uid, msg)
	--TODO �˴�Ӧ��¼������Ϣ��������ٶ�
	--�����Ϊgameģʽ
	local centerd = libcenter.fetch_centerd(uid)
	assert(centerd)
	skynet.send(centerd, "lua", "send_agent", uid, "send", msg)
end
return M