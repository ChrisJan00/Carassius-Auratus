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

Hook = class(function(self)
	self.pos = Vector(0,0)
	self.hook_pos = Vector(0,0)
	self.top = Vector(screensize[1]*3/4, -screensize[2]/2)

	self.picture = love.graphics.newImage("hook.png")
	self.hook_len = self.picture:getHeight()

	self.dir = Vector(0,0)
	self.speed = 0
	self.soft_damp = 1.2
	self.hard_damp = 2.6

	self.pull_dir = Vector( 0,0 )
	self.pull_speed = 0
	self.max_pull_speed = 300

	self.base_dir = Vector(0,0)
	self.base_speed = 0
	self.center_dir = Vector(0,0)
	self.center_speed = 0

	self.wind_dir = Vector(1,0)
	self.wind_speed = 0
	self.wind_max_speed = 20

	self.attracted = nil
	self.hooked = nil


	self.gravity = 50
	self.delay = 0

	self.fish_count = 0

	-- states:
	--  waiting, outside of the screen: until the player presses
	--  falling (thrown):  as long as the player presses
	--  pulling (without fish):  waits down, as the user presses, it pulls
	--  pulling (with fish):  same, fish can escape
	--  out: reaches out of screen
	self.state = 0

	self.pulling = false
	self.waiting_counter = 0
	self.catch_in_row = 0
	self.escape_in_row = 0
	self.hooked_time = 0
	self.hooked_limit = 1.4
	self.min_hooked_limit = 0.4
	self.max_hooked_limit = 2.0

	self.patience_time = 50
	self.min_patience_time = 10
	self.max_patience_time = 360

	self.attract_speed = 90
	self.min_attract_speed = 70
	self.max_attract_speed = 180
	self.escape_speed = 100
	self.attract_distance = 100
	self.view_angle = math.pi/3

	self.loosing_speed = 250
	self.min_loosing_speed = 100
	self.max_loosing_speed = 280

end)

-- difficulty:
-- the more you wait, the easier they bite
-- when they bite too easy, it becomes harder
-- pulling:  the more they escape, the easier
-- the less they escape, the harder.. count time since last catch...
-- count

function Hook:update(dt)
	-- special conditions
	if self.state==0 then
		if self.delay > 0 then
			self.delay = self.delay - dt
		end
	end

	if self.state==1 then
	end

	if self.state==2 then
		-- pulling dynamics
		self.speed = self.speed * math.exp(- self.hard_damp * dt)
		if self.pulling then
			self.pull_dir = self.pos:diff( self.top ):normalize()
			self.pull_speed = self.pull_speed + (self.max_pull_speed-self.pull_speed) * (1-math.exp( -2.8 * dt ))
		else
			self.pull_speed = self.pull_speed * math.exp( -2.8 * dt )
		end

		-- detect out of water
		if self.pos[2]<0 then
			self.state = 3
			Sounds.play(Sounds.plopout)
		end

		-- track waiting time
		if self.attracted or self.hooked then
			self.waiting_counter = 0
		else
			self.waiting_counter = self.waiting_counter+dt
		end
		self.attract_speed = self.min_attract_speed + (self.max_attract_speed-self.min_attract_speed)*self.waiting_counter/self.patience_time

		-- fish patience
		if self.hooked and not self.pulling then
			self.hooked_time = self.hooked_time+dt
			if self.hooked_time>self.hooked_limit then
				self:notifyEscaped()
			end
		else
			self.hooked_time = 0
		end
	end

	if self.state==3 then
	end

	-- normal update


	self.dir = Vector(0,0):add(
		self.base_dir:smul(self.speed),
		self.pull_dir:smul(self.pull_speed),
		self.center_dir:smul(self.center_speed),
		self.wind_dir:smul( self.wind_speed ) )

	self:move(dt)

	self.hook_pos = self.hook_pos:add(Vector(0,dt*self.gravity))
	self.hook_pos = self.pos:diff(self.hook_pos):normalize():smul(self.hook_len):add(self.pos)

	-- friction
	if self.pos[2]>0 then
		self.speed = self.speed * math.exp(- self.soft_damp * dt)

		-- avoid borders
		self.center_dir = self.pos:diff( Vector(screensize[1]/2, screensize[2]/2 ) )
		self.center_speed = self.pos:distance( { screensize[1]/2, screensize[2]/2 } ) * 100 / screensize[1]

		-- "wind" (submarine currents)
		self.wind_dir = self.wind_dir:rotate( math.pi*(math.random() - 0.5)*dt )
		self.wind_speed = self.wind_speed + dt * (math.random() * 100 - 50 )
		if self.wind_speed<0 then self.wind_speed = 0 end
		if self.wind_speed > self.wind_max_speed then self.wind_speed = self.wind_max_speed end
	end

end

function Hook:move(dt)
	self.pos = self.pos:add( self.dir:smul( dt ) )

	if self.pos[1] < 0 then self.pos[1] = 0 end
	if self.pos[1] > screensize[1] then self.pos[1] = screensize[1] end
	if self.pos[2] > screensize[2]	then self.pos[2] = screensize[2] end
end


function Hook:draw()
	if self.status==0 then return end

	love.graphics.setColor(0,0,0)
	love.graphics.setLine(2)
	love.graphics.line( self.pos[1], self.pos[2], self.top[1], self.top[2] )
	love.graphics.draw(self.picture, self.pos[1], self.pos[2], (self.pos:diff(self.hook_pos):angle()-math.pi/2) , 1, 1, self.picture:getWidth()/2, 0 )

	love.graphics.setColor(255,255,255)

end

function Hook:press()
	self.pulling = true

	if self.state==0 and self.delay<=0 then
		-- begin throw
		self.base_dir = Vector( math.random()*5-4, 5 ):normalize()
		self.speed = 700
		self.state = 1
		self.pull_speed = 0
		self.hooked = nil
		self.attracted = nil

		-- difficulty adjustment
		self.waiting_counter = 0

		-- force start throw at the limit of the screen
		self.pos[1] = self.top[1] - self.base_dir[1]/self.base_dir[2]*self.top[2]
		self.pos[2] = 0
		self.hook_pos = self.pos:add(Vector(0,-self.hook_len))

		Sounds.play(Sounds.plopin)
		return
	end

	if self.state==1 then
		return
	end

	if self.state==2 then
		return
	end

	if self.state==3 then
		return
	end

end

function Hook:release()
	-- state 0 -> nothing
	self.pulling = false

	if self.state==0 then
		return
	end

	if self.state==1 then
		self.state=2
		return
	end

	if self.state==2 then
		return
	end

	if self.state==3 then
		self.state=0
		self.delay=1.4
		return
	end


end

function Hook:hasFish()
	return self.hooked or self.attracted
end

function Hook:attach( fish )
	self.hooked = fish
end

function Hook:notifyEscaped()
	if self.hooked then
		self.hooked.dir = self.pos:diff( self.hooked.pos ):rotate( math.random()*math.pi - math.pi/2)
		self.hooked.speed = self.loosing_speed
		self.hooked = nil
	end
	self.attracted = nil

	self.escape_in_row = self.escape_in_row + 1
	self.loosing_speed = self.loosing_speed + 10
	if self.loosing_speed > self.max_loosing_speed then
		self.loosing_speed = self.max_loosing_speed
	end

	self.hooked_limit = self.hooked_limit + 0.2
	if self.hooked_limit > self.max_hooked_limit then
		self.hooked_limit = self.max_hooked_limit
	end

	self.patience_time = self.patience_time - 10
	if self.patience_time < self.min_patience_time then
		self.patience_time = self.min_patience_time
	end

	self.catch_in_row = 0
	Sounds.play(Sounds.escape)
end

function Hook:notifyCatched()
	self.fish_count = self.fish_count + 1
	self.catch_in_row = self.catch_in_row + 1
	self.loosing_speed = self.loosing_speed - 10
	if self.loosing_speed < self.min_loosing_speed then
		self.loosing_speed = self.min_loosing_speed
	end

	self.hooked_limit = self.hooked_limit - 0.2
	if self.hooked_limit < self.min_hooked_limit then
		self.hooked_limit = self.min_hooked_limit
	end

	self.patience_time = self.patience_time + 10
	if self.patience_time > self.max_patience_time then
		self.patience_time = self.max_patience_time
	end

	self.escape_in_row = 0
	Sounds.play(Sounds.scored)
end
