local skynet = require "skynet"
local websocket = require"websocket"
local protopack = require "protopack"
local env = require "env"
local log = require "log"

require "service"
require "login.login"


function default_dispatch(cmd, fd, msg, source)
    local cb = env.forward[cmd]
    if type(cb) ~= "function" then
        log.error("cb is not function, cmd = %s, str = %s", cmd, str)
        return
    end

    local isok, ret = pcall(cb, fd, msg, source)
    if not isok then
        log.error("handle msg error, cmd = %s, str = %s, err=%s", cmd, str, ret)
        return
    end
    return ret 
end



