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

Fish = class(function(self)
	self.img = love.graphics.newImage("redfish1.png")
	self.img_cache = love.graphics.newImage("redfish2.png")
	self.img_timer = 0
	self.pos = Vector( math.random(screensize[1]) , math.random(screensize[2]) )
	self.dir = Vector( math.random(), math.random() ):normalize()
	self.angular_dir = 0
	self.accel = 50 -- pixels/ s**2
	self.steering = 3 -- rad/s
	self.min_speed = 20
	self.max_speed = 300
	self.speed = math.random( self.max_speed - self.min_speed ) + self.min_speed -- pixels/s
	self.min_angular = -2
	self.max_angular = 2
end)

function Fish:connect( school, hook )
	self.school = school
	self.hook = hook
end

function Fish:draw()
	if self.dir[1]>=0 then
		love.graphics.draw( self.img, self.pos[1], self.pos[2], self.dir:angle(), 1, 1, self.img:getWidth()/2, self.img:getHeight()/2 )
	else
		love.graphics.draw( self.img, self.pos[1], self.pos[2], -self.dir:angleDiff({-1,0}), -1, 1, self.img:getWidth()/2, self.img:getHeight()/2)
	end
end

function Fish:advance(dt)
	self.pos = self.pos:add( self.dir:smul( self.speed * dt ) )

	if self.pos[1] < 0 then
		self.pos[1] = self.pos[1] + screensize[1]
	end

	if self.pos[1] > screensize[1] then
		self.pos[1] = self.pos[1] - screensize[1]
	end

	if self.pos[2] < 0 then
		self.dir[2] = -self.dir[2]
		self.pos[2] = -self.pos[2]
	end

	local limitDown = screensize[2] - self.img:getHeight()
	if self.pos[2] > limitDown then
		self.pos[2] = 2 * limitDown - self.pos[2]
		self.dir[2] = -self.dir[2]
	end
end

function randomSign()
	if math.random()<0.5 then
		return -1
	else
		return 1
	end
end

function Fish:update( dt )
	if self.img_timer <= 0 then
		self.img_timer = 0.1 * self.max_speed / self.speed
		local tmp = self.img
		self.img = self.img_cache
		self.img_cache = tmp
	else
		self.img_timer = self.img_timer - dt
	end

	self:attract()


	if self.hook.attracted == self then
		self.speed = self.speed * 0.9 + self.hook.dir:mag() * 0.1
	else
		self.speed = self.speed - math.log(1-math.random()) * self.accel * dt * randomSign()
	end
	if self.speed < self.min_speed then self.speed = self.min_speed end
	if self.speed > self.max_speed then self.speed = self.max_speed end

	if self.hook.attracted == self then		self.angular_dir = self.angular_dir * 0.9 + 0.1 * self.dir:angleDiff( self.pos:diff(self.hook.pos) )
	else
		self.angular_dir = self.angular_dir * 0.9 * dt
		self.angular_dir = self.angular_dir - math.log(1-math.random()) * self.steering * dt * randomSign()
	end

	if self.angular_dir < self.min_angular then self.angular_dir = self.min_angular end
	if self.angular_dir > self.max_angular then self.angular_dir = self.max_angular end
	self.dir = self.dir:rotate( self.angular_dir )

	if self.hook.attracted == self and (not self.hook.hooked) and self.pos:distance( self.hook.pos ) < 6 then
		self.hook.hooked = self
	end

	self:advance( dt )

	if self.hook.attracted==self and self.hook.dir:mag() > self.hook.loosing_speed then
		self.hook.hooked = nil
		self.hook.attracted = nil
		self.dir = self.hook.pos:diff( self.pos )
	end

	if self.hook.hooked == self then
		self.pos = self.hook.pos
		if self.pos[2] < 0 then
			self.school.list:removeCurrent()
			self.hook.fish_count = self.hook.fish_count + 1
		end
	end

end

function Fish:attract()
	if not self.hook.thrown then return end
	if self.hook.pos[2]<0 then return end
	if self.hook:hasFish() then return end
	if self.speed > 100 then return end
	if self.hook.dir:mag() > 100 then return end
	if self.pos:distance( self.hook.pos ) > 80 then return end
	if math.abs( self.dir:angle(self.pos:diff( self.hook.pos ) ) ) > 3.1416 / 4 then return end
	self.hook.attracted = self
end


---------------------------------------------------------------------------------------

School = class(function(self)
	self.list = List()
end)

function School:generate( n )
	for i=1,n do
		self.list:pushBack( Fish() )
	end
end

function School:draw()
	local fish = self.list:getFirst()
	while fish do
		fish:draw()
		fish = self.list:getNext()
	end
end

function School:update(dt)
	local fish = self.list:getFirst()
	while fish do
		fish:update(dt)
		fish = self.list:getNext()
	end
end

function School:connect(hook)
	local fish = self.list:getFirst()
	while fish do
		fish:connect(self, hook)
		fish = self.list:getNext()
	end
end
