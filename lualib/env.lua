local M = {}
M.id = 0
M.players = {}
M.fds = {}

--lua转发的消息
M.dispatch = {}
--agent转发的客户端消息
M.forward = {}
--agent记录的forward路由
M.service = {}

return M

