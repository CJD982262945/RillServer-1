local skynet = require "skynet"
local cluster = require "skynet.cluster"
local log = require "log"
require "skynet.manager"
local runconf = require(skynet.getenv("runconfig"))
local servconf = runconf.service
local nodename = skynet.getenv("nodename")

local function start_host()
    skynet.uniqueservice("host", "host")
    log.debug("start host server ")
end

local function start_console()
	for i,v in pairs(servconf.debug_console) do
		if nodename == v.node then
			skynet.uniqueservice("debug_console", v.port)
			log.debug("start debug_console in port: " .. v.port.."...")
		end
	end
end

local function start_setup()
	log.debug("start setupd...")
	local p = skynet.newservice("setup", "setup", 0)
end

local function start_gateway()
	for i, v in pairs(servconf.gateway) do
		local name = string.format("gateway%d", i)
		if nodename == v.node then
			local p = skynet.newservice("gateway", "gateway", i)
			local c = servconf.gateway_common
			local g = servconf.gateway[i]
			skynet.name(name, p)
			log.debug("start "..name.."...")
			skynet.call(p, "lua", "open", {
				port = g.port,
				maxclient = c.maxclient,
				nodelay = c.nodelay,
				name = name,
			})
		else
			local proxy = cluster.proxy(v.node, name)
			skynet.name(name, proxy)
		end
	end
end

local function start_login()
	for i,v in pairs(servconf.login) do
		local name = string.format("login%d", i)
		if nodename == v.node then
			local p = skynet.newservice("login", "login", i)
		else
			local proxy = cluster.proxy(v.node, name)
			skynet.name(name, proxy)
		end
	end
end

local function start_game()
	--开启game服务
	for i,v in pairs(servconf.game) do
		local name = string.format("game%d", i)
		if nodename == v.node then
			local p = skynet.newservice("game", "game", i)
		else
			local proxy = cluster.proxy(v.node, name)
			skynet.name(name, proxy)
		end
	end
end

local function start_dbproxy()
	for i,v in pairs(servconf.dbproxy) do
		local name = string.format("dbproxy%d", i)
		if nodename == v.node then
			local p = skynet.newservice("dbproxy", "dbproxy", i)
			--skynet.call(p, "lua", "dbproxy.start", servconf.dbproxy_common)
		else
			local proxy = cluster.proxy(v.node, name)
			skynet.name(name, proxy)
		end
	end
end

local function start_center()
	for i,v in pairs(servconf.center) do
		local name = string.format("center%d", i)
		if nodename == v.node then
			local p = skynet.newservice("center", "center", i)
		else
			local proxy = cluster.proxy(v.node, name)
			skynet.name(name, proxy)
		end
	end
end

local function start_global()
	for i,v in pairs(servconf.global) do
		local name = string.format("global%d", i)
		if nodename == v.node then
			local p = skynet.newservice("global", "global", i)
		else
			local proxy = cluster.proxy(v.node, name)
			skynet.name(name, proxy)
		end
	end
end

local function start_scene_mgr()
    if servconf.scene then
        local p = skynet.uniqueservice("scene_mgr", "scene_mgr")
		skynet.call(p, "lua", "start")
    else
        log.debug("not scene conf, so not start scene mgr")
    end
end

skynet.start(function()

	log.debug("Server start version: " .. runconf.version)
	--集群信息
	cluster.reload(runconf.cluster)
	cluster.open(nodename)
	--开启各个服务
    --
	start_host()
	start_console()
	start_setup()
    start_scene_mgr()
	start_gateway()
	start_login()
	start_game()
	start_dbproxy()
	start_center()
	start_global()
	--exit
    skynet.exit()
end)


