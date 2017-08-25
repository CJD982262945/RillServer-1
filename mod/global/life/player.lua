do return end

local env = require "env"
local log = require "log"
local skynet = require "skynet"
local D = env.dispatch.life
local libsetup = require "libsetup"

local Player = {}
Player.__index = Player

Player.MAX_MOVE_SPEED = 200		--最高移动速度
Player.MOVE_ACCELERATED = 160	--移动加速的 
Player.GRAVITYSPEED = 180		--重力速度初始速度,非物理
Player.GRAVITY = 80				--重力加速度
Player.MARGIN = 10				--x边距
Player.BOUNDDOWN = 40			--上边界下落距离
Player.HIT_INTERVAL = 0.1
Player.INJ_BASE_DISTANCE = 120

function Player.new(o)
    local o = o or {
		uid = 0,
		x = 0, --readonly
		y = 0, --readonly
		face = 0,-- readonly -1:left 1:right 
		movespeed = 0,
		gravityspeed = 0,
		injspeed = 0, --injured_speed
		moveinput = 0,
		skin = 0,--皮肤
		--
		money = 0,
		wisdom = 0,
		age = 0,
		--
		last_hit_time = 0, --攻击相关
		last_bcld_time = 0, --building相关 last building collide time
		last_systatus_time = 0, --sync_status,
		agespeed = 0.29,			--50 年龄增长速度
		--
		game = nil, -- for convenience
		node = nil,
		room = nil,
		
		
	}
    setmetatable(o, Player)
    return o
end

--移动到math通用库
function math.sign(val)
	if val < 0 then return -1
	elseif val > 0 then return 1
	else return 0 end
end

--移动到math通用库
function math.clamp(val, min, max)
	if val < min then return min
	elseif val > max then return max
	else return val end
end

-- x-> -1:left 1:right 0:none
function Player:input(x, action)
	--die
	if self:agegroup() >= 5 then
		return
	end
	--move
	if x then
		self.moveinput = x 
		if x ~= 0 then self.face = x end
	end
	--action attack
	if action and action == 1 then
		self:hitaction()
	end
end

local function isinbox(x, y, box_x, box_y, box_w, box_h)
	if x < box_x then return false end
	if x > box_x + box_w then return false end
	if y < box_y then return false end
	if y > box_y + box_h then return false end
	return true
end
--攻击动作
function Player:hitaction(deltaTime)
	--time
	local timenow = skynet.time()
	if timenow - self.last_hit_time < Player.HIT_INTERVAL then
		return
	end
	self.last_hit_time = timenow
	--face
	if self.face == 0 then
		return
	end
	--get box
	local room = self.room
	local box_w, box_h = 40, 40
	local box_x, box_y = self.x, self.y-40+5 --face = 1
	if self.face == -1 then box_x = box_x - box_w end
	--collide
	for ouid, oplayer in pairs(room.players) do --other_uid other_player
		if ouid ~= self.uid and isinbox(oplayer.x, oplayer.y, box_x, box_y, box_w, box_h) then
			local dist = Player.INJ_BASE_DISTANCE*1
			oplayer.injspeed = self.face * dist --简化计算，一次的距离
			break --only one people
		end
	end
	D.broadcast(room, "life.action", {action=1, uid=self.uid})
end

--上下边界
function Player:boundcollide(deltaTime)
	local room = self.room
	local map = room.map
	--上边界
	if self.y < room.top then
		self.y = self.y + Player.BOUNDDOWN
		self.x = self.x
		self.face = self.face
		self.movespeed = 0
	end
	--下边界
	if self.y > room.top + env.life.MAP_HEIGHT  then
		local y, x, face = env.life.born_point(room)
		self.y = y
		self.x = x
		self.face = face
		self.movespeed = 0
	end
end
--移动物理
function Player:updatephysics(deltaTime)
	local room = self.room
	local map = room.map
	local row,index = env.life.coor2map(self.y, self.x)
	local building = map[row][index] --foot_building
	--movement input
	local accelerated = Player.MOVE_ACCELERATED*self.moveinput
	--sliding friction, not physical
	local speedsign = math.sign(self.movespeed) --move_speed_sign
	if building == 1 and speedsign ~= self.moveinput then
		self.movespeed = self.movespeed - speedsign*Player.MOVE_ACCELERATED*3
		if self.movespeed*speedsign < 0 then self.movespeed = 0 end -- same direction and sp >= 0
	end
	--movement physical
	self.movespeed = self.movespeed + accelerated * deltaTime
	self.movespeed = math.clamp( self.movespeed, -Player.MAX_MOVE_SPEED, Player.MAX_MOVE_SPEED)
	local xspeed = self.movespeed -- +self.injspeed
	
	--self.gravityspeed = Player.GRAVITYSPEED 
	self.gravityspeed = self.gravityspeed + Player.GRAVITY*deltaTime
	local yspeed = Player.GRAVITYSPEED + self.gravityspeed
	
	local dx = xspeed*deltaTime + self.injspeed --deltax
	local dy = yspeed*deltaTime
	local dbx = math.clamp(self.x + dx, Player.MARGIN, 40*8 - Player.MARGIN) - self.x  --Border judgment border
	if dbx ~= dx then self.movespeed = 0 end
	dx = dbx
	
	if building == 1 then dy = 0 end --stand on floor
	local rowd,indexd = env.life.coor2map(self.y + dy, self.x + dx) --rowd has moved
	local buildingd = map[rowd][indexd] --foot_building ed
	if buildingd == 1 then  --stand on floor
		dy = (rowd-1)*40 - self.y
		self.gravityspeed = 0
	end
	self.y = self.y + dy
	self.x = self.x + dx
end

--年龄增长
function Player:updateage(deltaTime)
	self.age = self.age + self.agespeed * deltaTime
	if self:agegroup() >= 5 then
		self.movespeed = 0
	end
end

function Player:update(deltaTime)
	self:updatephysics(deltaTime)
	self:boundcollide(deltaTime)
	self:buildingcollide()
	self:updateage(deltaTime)
	self.injspeed = 0
end

function Player:syncdata()
	local timenow = skynet.time()
	
	local d = {
		x = self.x,
		y = self.y,
		face = self.face,
		uid = self.uid
	}
	
	if timenow - self.last_systatus_time > 0.5 then
		self.last_systatus_time = timenow
		d.money = self.money
		d.wisdom = self.wisdom
		d.age = self.age
		log.info("xxx money:"..self.money.." wisdom:"..self.wisdom.." age:"..self.age)
	end
	
	return d
end

function Player:fulldata()
	local d = self:syncdata()
	d.skin = self.skin
	d.money = self.money
	d.wisdom = self.wisdom
	d.age = self.age
	return d
end

return Player