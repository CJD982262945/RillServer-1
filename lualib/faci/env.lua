local M = {}
--��������Ϣ
M.name = "nameless server"
M.id = 0

--����б��fd�б�ֻ������game
--�ַ��������env.fds[fd]���ض�Ӧ��player�ṹ��ֱ�Ӵ�fd
M.players = {}
M.fds = {}

--ģ��
M.module = {
	--[[
	login = {
		--luaת������Ϣ
		dispatch = {},
		--ת���Ŀͻ�����Ϣ
		forward = {},
		--�¼�
		event = {},
	}
	--]]
}

--ȫ�ֱ���
M.static = {
	--[[
		login = {}
	--]]
}

M.dispatch = {} --Ϊ�˲������ȵ���ģ����ص�����
M.forward = {}
M.events = {}
M.waiting_queue = {}

return M

