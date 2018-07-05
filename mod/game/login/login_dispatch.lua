local skynet = require "skynet"
local libdbproxy = require "libdbproxy"
local tool = require "tool"
local Player = require "game.player.player"
local runconf = require(skynet.getenv("runconfig"))

local faci = require "faci.module"
local module = faci.get_module("Login")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event


--false /true, skynet:self()
function dispatch.login(playerid, data)
	log.debug("%d player login", playerid)
	local player = Player.new(data)
    --从数据库里加载数据
    local playerdata = player:load_all_data()
	--初始化数据
	player.fd = data.fd
    player.addr = data.addr
	player.data = playerdata
	player.data.baseinfo.login_time = os.time()
    player.data.baseinfo.test_data = { key1 = {1, 2, { 5, 6}, {key1=5, key2={"112"} }}, key2=6, key7="string"}

	env.players[playerid] = player
	env.fds[data.fd] = playerid 
	--事件
	faci.fire_event("login", player)
    return true, skynet:self()
end


--false/true
function dispatch.kick(playerid, season)
	local player = env.players[playerid]
    if not player then
        return false
    end

	faci.fire_event("logout", player)
    player:save_all_data()

	env.players[playerid] = nil

    local fd = player.fd
	env.fds[fd] = nil
    env.waiting_queue[fd] = nil
	return true
end


