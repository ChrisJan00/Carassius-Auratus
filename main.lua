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
function love.filesystem.require(filename)
	local g = love.filesystem.load(filename)
	g()
end

function quit()
	love.event.push('q')
end

function love.load()

	-- Dependencies
	love.filesystem.require("class.lua")
	love.filesystem.require("vectors.lua")
	love.filesystem.require("linkedlists.lua")

	love.filesystem.require("fish.lua")
	love.filesystem.require("hook.lua")
	love.filesystem.require("weeds.lua")
	love.filesystem.require("bubbles.lua")
	love.filesystem.require("sounds.lua")

	-- Initialization
	start_time = love.timer.getTime()

	math.randomseed(os.time())

	-- Init graphics mode
--~ 	screensize = { 800, 600 }
	screensize = { 1024,768 }
	fullscreen = true
	if not love.graphics.setMode( screensize[1], screensize[2], fullscreen, true, 0 ) then
		screensize = { 800, 600 }
		if not love.graphics.setMode( screensize[1], screensize[2], fullscreen, true, 0 ) then
			quit()
		end
	end

	love.graphics.setBackgroundColor(0,0,0)
	love.graphics.setColor(255,255,255)
	love.graphics.setLine(1)

	-- Text
	love.graphics.setFont(32)

	-- Game data
	gameStatus = 0

	bgImage = love.graphics.newImage( "fishbg.png" )
	hook = Hook()
	fishSchool = School(hook)
	seaWeedsBack = Weeds()
	seaWeedsFront = Weeds()
	bubbles = Bubbles()


	keyDown = false
	endTimer = 0
end

function love.update(dt)

	if gameStatus==1 then
		fishSchool:update( dt )
		seaWeedsBack:update( dt )
		seaWeedsFront:update( dt )
		bubbles:update( dt )

		if keyDown then hook:press() else hook:release() end

		hook:update(dt)
	end

	if gameStatus==2 and endTimer>0 then
		endTimer = endTimer - dt
		if endTimer <= 0 then
			gameStatus = 3
		end
	end

	if fishSchool.list:count() == 0 and gameStatus==1 then
--~ 		gameStatus = 2
		endTimer = 4.5
	end
end


function love.draw()
	love.graphics.draw(bgImage, 0, 0)

	if gameStatus==0 then
		love.graphics.setFont(32)
		love.graphics.print("Carassius auratus", 70, 125)
		love.graphics.print("A fishing amusement", 70, 175)
		love.graphics.print("Press any key", 70, 225)
		love.graphics.print("by Christiaan Janssen", 400, 550)
		love.graphics.setFont(12)
		love.graphics.print("(m is for mute)", 70, 250)
		love.graphics.setFont(32)
		return
	end

	if fishSchool.list:count() == 0 and gameStatus==1 then
		love.graphics.print("The pond is empty.  Relax", 70, 150)
	end

	if gameStatus==1 then
		love.graphics.print(hook.fish_count, 30, 30)
--~ 		love.graphics.print(fishSchool.fish_count[1].." "..fishSchool.fish_count[2],30,30)
	end

	seaWeedsBack:draw()
	bubbles:draw()
	hook:draw()
	fishSchool:draw()
	seaWeedsFront:draw()

end


function love.keypressed(key)
	if key=="escape" then
		if gameStatus==1 then
			gameStatus=0
		else
			quit()
		end
		return
	end

	if key=="m" then
		Sounds.flip()
	end

	if gameStatus==0 then
		gameStatus=1
		fishSchool.list:discard()
		fishSchool = School(hook)
		fishSchool:spawn(25)
		fishSchool.timer=0
		return
	end

	keyDown = true

end


function love.keyreleased(key)
	keyDown = false

end


function love.mousepressed(x, y, button)
	love.keypressed(button)

end



function love.mousereleased(x, y, button)
	love.keyreleased(button)

end



