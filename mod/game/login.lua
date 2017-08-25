local skynet = require "skynet"
local libdbproxy = require "libdbproxy"
local tool = require "tool"
local Player = require "game.player"
local runconf = require(skynet.getenv("runconfig"))

local faci = require "faci.module"
local module = faci.get_module("login")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

local InitData = {}
function InitData.init_baseinfo()
    local ret = {
		name = "good man",
		register_time = os.time(),
		login_time = os.time(),
	}
    return ret
end

local function get_init_data(cname)
    local funname = string.format("init_%s", cname)
    local func = InitData[funname]
    assert(type(func) == "function")
    return func()
end

local function load_data(cname, uid)
    local ret = libdbproxy.get_playerdata(cname, uid)
    log.debug("===load_data cname: " .. cname .. " uid:" .. uid .. " ret: " .. tool.dump(ret))
	ret = ret or get_init_data(cname)
	ret._dirty = ret._dirty or true
	ret.uid = uid
    setmetatable(ret, {
			__newindex = function(t, k, v)
				log.error("not allow to add new playerdata %s.%s ", cname, k)
				assert(nil)
				t._dirty = true
				rawset(t, k, v)
        end})
    return ret
end

local function load_all_data(uid)
    local data = {}
    for k, v in pairs(runconf.playerdata) do
        data[k] = load_data(k, uid)
    end
    return data
end

--false /true, skynet:self()
function dispatch.login(uid, data)
	log.debug("%d player login", uid)
	player = Player.new()
    --从数据库里加载数据
	local playerdata = load_all_data(uid)
	--初始化数据
	player.uid = uid
	player.fd = data.fd
	player.data = playerdata
	player.data.baseinfo.login_time = os.time()
	
	
	env.players[uid] = player
	env.fds[data.fd] = uid 
	--事件
	faci.fire_event("login", player)
    return true, skynet:self()
end

local function save_data(uid)
	log.info("save_data "..uid)
	local player = env.players[uid]
    for k, v in pairs(player.data) do
        if v._dirty then
            v._dirty = nil
			log.info("save_data update "..k)
			local select = {uid=player.uid}
            libdbproxy.set_playerdata(k, player.uid, v)
        end
    end
end


function dispatch.kick(uid, season)
	save_data(uid)
	local player = env.players[uid]
	if player.fd then
		env.fds[player.fd] = nil
	end
	env.players[uid] = nil
	faci.fire_event("logout", player)
	--logout里的内容
	--dispatch.leave_room(player)
	--dispatch.life.leave_room(player)
	return true
end

function event.exit()
	--踢掉玩家
	for uid, player in pairs(env.players) do
		save_data(uid)
	end
end

function event.login()
	log.info("event.login")
end