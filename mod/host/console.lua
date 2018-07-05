local skynet = require "skynet"
local socket = require "skynet.socket"
local tool = require "tool"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"

local faci = require "faci.module"
local module = faci.get_module("console")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

local runconf = require(skynet.getenv("runconfig"))
local node = skynet.getenv("nodename")


local function send(fd, ...)
	local t = { ... }
	for k,v in ipairs(t) do
		t[k] = tostring(v)
	end
	socket.write(fd, table.concat(t,"\t"))
	socket.write(fd, "\n")
end
		
local function create_func(str)
    local fun_template = [[
        local skynet = require('skynet')
        return %s
    ]]

    local chunk = load(string.format(fun_template, str))
    return chunk
end

local function docmd(fd, cmdline)
    log.info("[docmd] " .. cmdline)
    local func = create_func(cmdline)
    func()
	send(fd, "ok")
end

local function show_help(fd)
end


local function main_loop(fd, addr)
	socket.start(fd)
	send(fd, "Welcome to host console")
	local ok, err = pcall(function()
		while true do
			local cmdline = socket.readline(fd, "\n")
			if not cmdline then
				break
			end
            if cmdline == "h" or cmdline == "help" then
                show_help(fd)
                return
            end

			if cmdline ~= "" then
				docmd(fd, cmdline)
			end
		end
	end)
	
	if not ok then
		skynet.error(fd, err)
	end
	skynet.error(fd, "disconnected")
	socket.close(fd)
end

function event.start()
	local cfg = runconf.service.host_common.console
	if node ~= cfg.node then
		return
	end
	
	local listenfd = socket.listen("127.0.0.1", cfg.port)
	log.info("Listen console port %d", cfg.port)
	
	socket.start(listenfd , function(fd, addr)
		log.info("connected %s%d", addr, fd)
		skynet.fork(main_loop, fd, addr)
	end)
end

