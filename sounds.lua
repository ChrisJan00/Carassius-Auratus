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

Sounds = {
	bubbles = love.audio.newSource("bubbles.ogg"),
	plopin = love.audio.newSource("plopin.ogg"),
	plopout = love.audio.newSource("plopout.ogg"),
	scored = love.audio.newSource("point.ogg"),
	bite = love.audio.newSource("bite.wav"),
	escape = love.audio.newSource("lost.wav")
}
Sounds.on = true

Sounds.bubbles:setVolume(0.5)
Sounds.plopin:setVolume(0.5)
Sounds.plopout:setVolume(0.5)
Sounds.scored:setVolume(0.5)
Sounds.bite:setVolume(0.5)
Sounds.escape:setVolume(0.5)

function Sounds.mute()
	Sounds.on = false
end

function Sounds.unmute()
	Sounds.on = true
end

function Sounds.play(snd)
	if Sounds.on then
		love.audio.play(snd)
	end
end
