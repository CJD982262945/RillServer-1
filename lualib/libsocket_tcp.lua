local driver = require "skynet.socketdriver"
local socket_write = assert(driver.send)

local tcplib = {}

function tcplib.send(fd, data)
	socket_write(fd, data)
end

return tcplib
