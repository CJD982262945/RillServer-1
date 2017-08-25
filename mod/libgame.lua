local skynet = require "skynet"
local log = require "log"

local runconf = require(skynet.getenv("runconfig"))
local servconf = runconf.service

local M = {}

local game = {}
local game_num = 0

local function init()
	local node = skynet.getenv("nodename")
	for i,v in pairs(servconf.game) do
		if node == v.node then
			table.insert(game, string.format("game%d", i))
			game_num = game_num + 1
		end
	end
end

function M.login(uid, data)
    local game = game[math.random(1, game_num)]
    assert(game)
    local isok, game = skynet.call(game, "lua", "login.login", uid, data)
    return isok, game
end



skynet.init(init)

return M


