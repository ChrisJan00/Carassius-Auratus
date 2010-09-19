-- Carassius auratus
-- Copyright 2010  Christiaan Janssen, August 2010
--
-- This file is part of Carassius auratus
--
--     Carassius auratus is free software: you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation, either version 3 of the License, or
--     (at your option) any later version.
--
--     Carassius auratus is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
--
--     You should have received a copy of the GNU General Public License
--     along with Carassius auratus  If not, see <http://www.gnu.org/licenses/>.

Bubble = class(function(self,x,y)
	self.pos=Vector((x or 400)+math.random(6)-3,(y or 400)+math.random(6)-3)
	self.speed=Vector(30,10+math.random(10))
	self.life=math.random()*15+1
	self.half_life=self.life* (1-1/3.5)
	self.radius=0
	self.growth=1
	self.size=0
end)

function Bubble:draw()
	love.graphics.circle( "line", self.pos[1], self.pos[2], self.size )
end

function Bubble:update(dt)
	self.life = self.life - dt
	if self.life <= 0 then return false end
	if self.life>=self.half_life then
		self.size = self.size + dt*self.growth
	else
		self.size = self.size - dt*self.growth*(1-1/3.5)
		if self.size<0 then return false end
	end

	self.pos = self.pos:add(Vector((math.random()-0.5)*self.speed[1]*dt, -self.speed[2]*dt))
	return true
end


Bubbles = class(function(self)
	self.list = List()
	self.period = math.random(20)+15
	self.active = 0
	self.timer = 0
end)

function Bubbles:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.setLine(1)
	local bubble = self.list:getFirst()
	while bubble do
		bubble:draw()
		bubble = self.list:getNext()
	end
	love.graphics.setColor(255,255,255)
end

function Bubbles:update(dt)
	-- generate
	self.period = self.period - dt
	if self.period <= 0 then
		self.period = math.random(20)+10
		self.x, self.y = math.random(screensize[1]),math.random(screensize[2]*2/3)+screensize[2]*1/3
		self.active = math.random()*2+1
		self.timer = 0
		Sounds.play(sounds.bubbles)
	end
	if self.active>0 then
		self.active = self.active - dt
		self.timer = self.timer - dt
		if self.timer <= 0 then
			self.list:pushBack(Bubble(self.x,self.y))
			self.timer = 0.2
		end
	end

	-- update the living ones
	local bubble = self.list:getFirst()
	while bubble do
		if not bubble:update(dt) then self.list:removeCurrent() end
		bubble = self.list:getNext()
	end
end
