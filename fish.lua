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

min_fish = 2
max_fish = 22

Fish = class(function(self, ftype)
	if math.random(3)>1 then
		self.type = 1
	else
		self.type = 2
	end
	self.type = ftype or self.type

	if self.type==1 then
		self.img = love.graphics.newImage("redfish1.png")
		self.img_cache = love.graphics.newImage("redfish2.png")
		self.accel = 30
		self.steering = 2
		self.min_speed = 10
		self.max_speed = 250
		self.min_angular = -2
		self.max_angular = 2
	else
		self.img = love.graphics.newImage("yellfish1.png")
		self.img_cache = love.graphics.newImage("yellfish2.png")
		self.accel = 50 -- pixels/ s**2
		self.steering = 3 -- rad/s
		self.min_speed = 20
		self.max_speed = 300
		self.min_angular = -3
		self.max_angular = 3
	end
	self.img_timer = 0
	self.pos = Vector( math.random(screensize[1]) , math.random(screensize[2]) )
	self.dir = Vector( math.random()-0.5, math.random()-0.5 ):normalize()
	self.angular_dir = 0
	self.speed = math.random( self.max_speed - self.min_speed ) + self.min_speed -- pixels/s
	self.status = 1
	-- status = 0 <-- exit screen
	-- status = 1 <-- normal
	-- status = 2 <-- enter screen

end)

function Fish:setStatus( st )
	self.status = st
	if st==2 then
		if self.dir[1]>=0 then
			self.pos[1] = -40
		else
			self.pos[1] = screensize[1]+40
		end
	end
end

function Fish:connect( school, hook )
	self.school = school
	self.hook = hook
	self.school.fish_count[self.type] = self.school.fish_count[self.type]+1
end

function Fish:draw()
	if self.dir[1]>=0 then
		love.graphics.draw( self.img, self.pos[1], self.pos[2], self.dir:angle(), 1, 1, self.img:getWidth()/2, self.img:getHeight()/2 )
	else
		love.graphics.draw( self.img, self.pos[1], self.pos[2], -self.dir:angleDiff({-1,0}), -1, 1, self.img:getWidth()/2, self.img:getHeight()/2)
	end
end

function Fish:advance(dt)
	if self.state==2 then
		if self.pos[1]<0 and self.dir[1]<0 then self.dir[1]=-self.dir[1] end
		if self.pos[1]>screensize[1] and self.dir[1]>0 then self.dir[1]=-self.dir[1] end
	end

	self.pos = self.pos:add( self.dir:smul( self.speed * dt ) )

	if self.pos[1] < 0 and self.status==1 then
		self.pos[1] = self.pos[1] + screensize[1]
	end

	if self.pos[1] > screensize[1] and self.status==1 then
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
	if self.status==0 and (self.pos[1]<-30 or self.pos[1]>screensize[1]+30) then
		self:disappear()
		return
	end
	if self.status==2 and self.pos[1]>0 and self.pos[1]<screensize[1] then
		self.status=1
	end

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
			self:disappear()
			self.hook.fish_count = self.hook.fish_count + 1
		end
	end

end

function Fish:attract()
	if not self.hook.thrown then return end
	if self.hook.pos[2]<0 then return end
	if self.hook:hasFish() then return end
	if self.speed > 150 then return end
	if self.hook.dir:mag() > 100 then return end
	if self.pos:distance( self.hook.pos ) > 100 then return end
	if math.abs( self.dir:angle(self.pos:diff( self.hook.pos ) ) ) > math.pi / 4 then return end
	self.hook.attracted = self
end

function Fish:disappear()
	self.school.list:remove(self)
	self.school.fish_count[self.type] = self.school.fish_count[self.type]-1
end


---------------------------------------------------------------------------------------

School = class(function(self, hook)
	self.list = List()
	self.fish_count = {0,0}
	self.period = {15*60, 24*60*math.pi/3}
	self.hook = hook
	self.timer = 0
end)

function School:generate( n, ftype )
	for i=1,n do
		self.list:pushBack( Fish(ftype) )
		self.list:getLast():connect(self, self.hook)
		self.list:getLast():setStatus(2)
	end
end

function School:spawn( n )
	self:generate( n )
	fish = self.list:getFirst()
	while fish do
		fish.pos[1] = math.random(screensize[1])
		fish = self.list:getNext()
	end
end

function School:kill( n, ftype )
	local fish = self.list:getFirst()
	if ftype then
		if n>self.fish_count[ftype] then n=self.fish_count[ftype] end
		for i=1,n do
			while fish.type~=ftype or fish.status == 0 do
				fish = self.list:getNext()
				if not fish then return end
			end

			fish:setStatus(0)
		end
	else
		if n>self.fish_count[1]+self.fish_count[2] then
			n=self.fish_count[1]+self.fish_count[2]
		end
		for i=1,n do
			while fish.status == 0 do
				fish = self.list:getNext()
				if not fish then return end
			end

			fish:setStatus(0)
		end
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
	-- update the population
	self:updatePopulations( dt )
	-- update the fish
	local fish = self.list:getFirst()
	while fish do
		fish:update(dt)
		fish = self.list:getNext()
	end
end

function School:updatePopulations( dt )
	self.timer = self.timer + dt
	if self.timer > self.period[1]*self.period[2] then self.timer = self.timer - self.period[1]*self.period[2] end
	local desired = { math.floor(min_fish + (max_fish-min_fish)*(1+math.sin( self.timer * 2 * math.pi / self.period[1] )/2) + 0.5),
					   math.floor(min_fish + (max_fish-min_fish)*(1+math.sin( self.timer * 2 * math.pi / self.period[2] )/2) + 0.5) }

	for i=1,2 do
		if self.fish_count[i]<desired[i] then
			self:generate(desired[i]-self.fish_count[i],i)
		elseif self.fish_count[i]>desired[i] then
			self:kill(self.fish_count[i]-desired[i],i)
		end
	end
end


--~ function School:connect(hook)
--~ 	local fish = self.list:getFirst()
--~ 	while fish do
--~ 		fish:connect(self, hook)
--~ 		fish = self.list:getNext()
--~ 	end
--~ end
