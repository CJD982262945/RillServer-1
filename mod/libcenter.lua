local skynet = require "skynet"

local runconf = require(skynet.getenv("runconfig"))
local servconf = runconf.service
local MAX_CENTER_COUNT = #servconf.center


local M = {}
local centers = {}

local function init()
   for i = 1, MAX_CENTER_COUNT do
    centers[i] = string.format("center%d", i)
   end
end

function M.fetch_centerd(playerid)
    local id = playerid % MAX_CENTER_COUNT + 1
    return centers[id]
end


function M.login(playerid, data)
    local center = M.fetch_centerd(playerid)
    assert(center)
    return skynet.call(center, "lua", "Login.login", playerid, data)
end

function M.register(playerid, data)
    local center = M.fetch_centerd(playerid)
    assert(center)
    return skynet.call(center, "lua", "Login.register", playerid, data)
end

function M.logout(playerid, key)
    local center = M.fetch_centerd(playerid)
    assert(center)
    return skynet.call(center, "lua", "Login.logout", playerid, key)
end


function M.broadcast(cmd, ...)
	for i = 1, MAX_CENTER_COUNT do
		skynet.send(centers[i], "lua", cmd, ...)
   end
end

function M.send2client(playerid, msg)
    local center = M.fetch_centerd(playerid)
    assert(center)
	skynet.call(center, "lua", "Broadcast.send2client", playerid, msg)
end

function M.broadcast2client(msg)
	M.broadcast("Broadcast.broadcast2client", msg)
end

skynet.init(init)

return M


