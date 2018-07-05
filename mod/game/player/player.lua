local skynet = require "skynet"
local libdbproxy = require "libdbproxy"
local tool = require "tool"
local runconf = require(skynet.getenv("runconfig"))
local protoconf = runconf.protopack
local pb = require("protobuf")
local tracedoc = require("tracedoc")


local PLAYER_ALL_DATA = {
    baseinfo = true,
}

local Player = {}

Player.__index = Player

function Player.new(o)
    local o = o or {}
    --o.playerid = o.playerid or -1
    --o.fd = -1
    o.romote = {} --记录的forward路由
    setmetatable(o, Player)
    return o
end

-- 加载玩家数据
function Player:load_all_data()
    local playerid = self.playerid
    local playerdata = libdbproxy.get_playerdata(PLAYER_ALL_DATA, playerid)
    log.debug("===load_data playerid:" .. playerid .. " ret: " .. tool.dump(playerdata))

    local data = {}
    for k in pairs(PLAYER_ALL_DATA) do
        local v = playerdata[k] or {}
        data[k] = tracedoc.new(v)
        tracedoc.commit(data[k])
    end

    return data
end

--保持玩家数据
function Player:save_all_data()
	local player = self
   
    local save_player_data = {}
    for k, v in pairs(player.data) do
        if tracedoc.commit(v) then
            save_player_data[k] = v
        end
    end

    local ret = libdbproxy.set_playerdata(player.playerid, save_player_data)
    log.debug("save: " .. player.playerid .. " ret: " .. tool.dump(save_player_data))
end

function Player:send(msg)
    skynet.send(self.gate, "lua", "send", self.fd, msg)
end

return Player


