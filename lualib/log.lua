local skynet = require "skynet"
local runconf = require(skynet.getenv("runconfig"))

local logger = {}

local loglevel = {
    debug = 1,
    info = 2,
    warn = 3,
    err = 4,
}

local function init_log_level()
    if not logger._level then
        local level = skynet.getenv("log_level")
        local default_level = loglevel.debug
        local val

        if not level or not loglevel[level] then
            val = default_level
        else
            val = loglevel[level]
        end

        logger._level = val
    end
end

local function none_format()
    local format = "%s%s"
    return format
end

local function red_format()
    local format = string.char(0x1b).."[0;32;31m%s%s"..string.char(0x1b).."[0m"
    return format
end

local function light_red_format()
    local format = string.char(0x1b).."[1;31m%s%s"..string.char(0x1b).."[0m"
    return format
end

local function green_format()
    local format = string.char(0x1b).."[0;32;32m%s%s"..string.char(0x1b).."[0m"
    return format
end

local function light_green_format()
    local format = string.char(0x1b).."[1;34m%s%s"..string.char(0x1b).."[0m"
    return format
end

local function blue_format()
    local format = string.char(0x1b).."[0;32;34m%s%s"..string.char(0x1b).."[0m"
    return format
end

local function light_blue_format()
    local format = string.char(0x1b).."[1;34m%s%s"..string.char(0x1b).."[0m"
    return format
end


local function cyan_format()
    local format = string.char(0x1b).."[0;36m%s%s"..string.char(0x1b).."[0m"
    return format
end

local function light_cyan_format()
    local format = string.char(0x1b).."[1;36m%s%s"..string.char(0x1b).."[0m"
    return format
end

local function yellow_format()
    local format = string.char(0x1b).."[1;33m%s%s"..string.char(0x1b).."[0m"
    return format
end

local function logmsg(level, format, ...)
	local n = logger._name and string.format("[%s] ", logger._name) or ""
    local str = string.format(format, ...)
    local _format = none_format()
    if runconf.TEST then
        if level == loglevel.err then
            _format = red_format()
        elseif level == loglevel.warn then
            _format = yellow_format()
        elseif level == loglevel.info then
            _format = cyan_format()
        end
    end
    local msg = string.format(_format, n, str)
    skynet.error(msg)
end

function logger.set_log_level(level)
    local val = loglevel.debug

    if level and loglevel[level] then
        val = loglevel[level]
    end

    logger._level = val
end

function logger.debug(format, ...)
    if logger._level <= loglevel.debug then
        logmsg(loglevel.debug, format, ...)
    end
end

function logger.info(format, ...)
    if logger._level <= loglevel.info then
        logmsg(loglevel.info, format, ...)
    end
end

function logger.warn(format, ...)
    if logger._level <= loglevel.warn then
        logmsg(loglevel.warn, format, ...)
    end
end

function logger.error(format, ...)
    if logger._level <= loglevel.err then
        logmsg(loglevel.error, format, ...)
    end
end

init_log_level()

function logger.set_name(name)
    logger._name = name
end

return logger

