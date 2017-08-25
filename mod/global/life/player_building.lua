do return end

local env = require "env"
local log = require "log"
local skynet = require "skynet"
local D = env.dispatch.life
local libsetup = require "libsetup"
local Player = require "global.life.player"
local tool = require "tool"

--计算年龄阶段
function Player:agegroup()
	if self.age > 70 then return 5  		--死亡
	elseif self.age > 55 then return 4	 	--老年
	elseif self.age > 40 then return 3  	--中年
	elseif self.age > 25 then return 2  	--青年
	elseif self.age > 10 then return 1  	--少年
	else return 0 end						--儿童
end

--满足年龄条件
function Player:fitage(building)
	local cfg = libsetup.lifebuilding[building]
	local cond = cfg.condition.agegroup --condition
	if not cond then return true end
	local agegroup = self:agegroup()
	for i, v in ipairs(cond) do
		if agegroup == v then return true end
	end
	return false
end

--满足智慧条件
function Player:fitwisdom(building)

	local cfg = libsetup.lifebuilding[building]
	local cond = cfg.condition.wisdom --condition
	if not cond then return true end
	
	if self.wisdom >= cond then return true end
	return false
end

--是否满足条件
function Player:fitcondition(building)
	local cfg = libsetup.lifebuilding[building]
	if not cfg or not cfg.condition then return false end
	return self:fitage(building) and self:fitwisdom(building)
end

--计算数值
function Player:addvaule(building)
	local cfg = libsetup.lifebuilding[building]
	local money = 0
	local wisdom = 0
	--value1
	if cfg.addtype and cfg.addval then
		if cfg.addtype == 1 then money = money + cfg.addval end
		if cfg.addtype == 2 then wisdom = wisdom + cfg.addval end
	end
	--value2
	if cfg.addtype2 and cfg.addval2 then
		if cfg.addtype2 == 1 then money = money + cfg.addval2 end
		if cfg.addtype2 == 2 then wisdom = wisdom + cfg.addval2 end
	end
	--处理
	self.money = self.money + money
	self.wisdom = self.wisdom + wisdom
	if self.money < 0 then self.money = 0 end
	if self.wisdom < 0 then self.wisdom = 0 end
end

--碰撞
function Player:buildingcollide()
	--time
	local timenow = skynet.time()
	if timenow - self.last_bcld_time < 1 then
		return
	end
	self.last_bcld_time = timenow
	---body_building
	local row,index = env.life.coor2map(self.y-20, self.x)
	local building = self.room.map[row][index]
	local cfg = libsetup.lifebuilding[building]
	--condition
	if not self:fitcondition(building) then
		return
	end
	--add
	self:addvaule(building)
	--disappear
	if cfg.eat and cfg.eat == 1 then
		self.room.map[row][index] = 0
		D.broadcast(self.room, "life.eat", {row=row, index=index})
	end
end