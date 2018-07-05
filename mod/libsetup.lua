local skynet = require "skynet"
local builder = require "skynet.datasheet.builder"
local datasheet = require "skynet.datasheet"
local log = require "log"

local M = {}

function M.get(t, v)
    local conf = datasheet.query(t)
    if not conf then
        return
    end
    v = tostring(v)
    return conf[v]
end

setmetatable(M, {
    __index = function(t, k)
        k = tostring(k)
        return datasheet.query(k)
    end
})

return M


