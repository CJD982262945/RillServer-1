local skynet = require "skynet"
local libdb = require "libdbproxy"
local libcenter = require "libcenter"
local libgame = require "libgame"
local tool = require "tool"
local faci = require "faci.module"
local runconf = require(skynet.getenv("runconfig"))
local uuid = require "uuid"

local module, static = faci.get_module("Login")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

local function register(account, password)
    if not account then
        log.debug("register not account")
        return false
    end
    local playerid = uuid.gen()
    local data = {
        playerid = playerid,
        account = account,
        password = password
    }
    local ret = libdb.set_accountdata(account, data)
    return true, playerid
end


function static.check_pw_test(msg)
    local account = msg.Account
    local password = "123456"
    if not account then
        log.debug("check pw not account")
        return false
    end

    local ret = libdb.get_accountdata(account)
    if not ret then
        local ret, playerid = register(account, password)
        if ret then
            return true, playerid
        end
        return false
    end

    if ret.password == password then
        return true, ret.playerid
    end

    return false
end



