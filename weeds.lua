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

C_gravity = 2
C_maxspeed = 60

Seaweed = class(function(self, xpos)
	self.length = math.random(300) + 100
	local nsegments = math.random(3) + 2

	self.lengths = {}
	self.angles = {}
	for i=1,nsegments do
		self.lengths[i] = self.length/(i+1)
		if i>1 then
			self.angles[i] = self.angles[i-1] + (math.random()-0.5)*math.pi/4
		else
			self.angles[i] = math.random() * math.pi
		end
	end

	self.vel = Vector(math.random(),math.random()):normalize()
	self.speed = math.random(C_maxspeed)
	self.goal = 0
	self.accel = 10
	self.xpos = xpos
	self.points = {Vector(xpos,screensize[2])}
	-- normalize
	for i=2,nsegments do
		self.points[i] = Vector(self.points[i-1][1] + self.lengths[i-1]*math.cos(self.angles[i-1]),
					self.points[i-1][2] - self.lengths[i-1]*math.sin(self.angles[i-1]))
	end
end)

function Seaweed:draw()
	for i=1,table.getn(self.points)-1 do
		love.graphics.setLine(table.getn(self.points)+2-i)
		love.graphics.line( self.points[i][1], self.points[i][2], self.points[i+1][1], self.points[i+1][2] )
	end
end

function Seaweed:update(dt)

	-- update current
	self.vel = self.vel:rotate( (math.random()-0.5) * math.pi / 4 * dt )
	if self.vel[2]>0 then self.vel[2] = -self.vel[2] end

	if self.speed > self.goal then
		self.speed = self.speed - self.accel * dt
		if self.speed <= self.goal then
			self.goal = math.random(C_maxspeed)
			self.vel = self.vel:rotate( math.random() * math.pi * 2 )
		end
	elseif self.speed < self.goal then
		self.speed = self.speed + self.accel * dt
		if self.speed >= self.goal then
			self.goal = 0
		end
	end

	if self.speed<0 then self.speed = 0 end
	if self.speed>C_maxspeed then self.speed = C_maxspeed end


	for i=2,table.getn(self.points) do

		self.points[i][2] = self.points[i][2] + dt * C_gravity
		self.points[i] = self.points[i]:add( self.vel:rotate( (math.random()-0.5) * math.pi / 8 ):smul( self.speed*i/(i+2) * dt ) )

		-- compute the screen coordinates
		local oldangle = self.angles[i-1]
		self.angles[i-1] = -self.points[i-1]:diff( self.points[i] ):angle()
		self.points[i] = Vector(self.points[i-1][1] + self.lengths[i-1]*math.cos(self.angles[i-1]),
					self.points[i-1][2] - self.lengths[i-1]*math.sin(self.angles[i-1]))
		if self.points[i][2]>screensize[2] then
			self.points[i][2] = screensize[2]
			self.angles[i-1] = -self.points[i-1]:diff( self.points[i] ):angle()
			self.points[i][2] = self.points[i-1][2] - self.lengths[i-1]*math.sin(self.angles[i-1])
		end
		local anglediff = self.angles[i-1] - oldangle
		self.angles[i] = self.angles[i] - 2* anglediff
		if i<table.getn(self.points) then
		self.points[i+1] = Vector(self.points[i][1] + self.lengths[i]*math.cos(self.angles[i]),
				self.points[i][2] - self.lengths[i]*math.sin(self.angles[i]))
		end
	end
end


------------------------------------------------------------------------

Weeds = class(function(self)
	self.list = List()

	for j=1,3 do
		local startpoint = math.random(10) * screensize[1] / 10
		for i=1,math.random(4)+1 do
			self.list:pushBack( Seaweed( startpoint ) )
		end
	end
end)


function Weeds:draw()
	love.graphics.setColor(20,70,30,160)
	local weed = self.list:getFirst()
	while weed do
		weed:draw()
		weed = self.list:getNext()
	end
	love.graphics.setColor(255,255,255)
end

function Weeds:update(dt)
	local weed = self.list:getFirst()
	while weed do
		weed:update(dt)
		weed = self.list:getNext()
	end
end

