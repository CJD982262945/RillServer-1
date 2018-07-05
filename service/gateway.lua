local name, id = ...
local log = require "log"
local env = require "faci.env"
log.set_name(name..id)
env.gateway_id = id

require "gateway.gate"

