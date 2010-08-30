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

-- Double Linked Lists
if not love then
	require 'class'
end

Vector = class( function(self, x, y)
	self[1] = x or 0
	self[2] = y or 0
end)

function Vector:x()
	return self[1]
end

function Vector:y()
	return self[2]
end

function Vector:mag()
	return math.sqrt( self[1]*self[1] + self[2]*self[2] )
end

function Vector:angle()
	return -self:angleDiff(Vector(1,0))
end

function Vector:rotate(angle)
	local c,s = math.cos(angle), math.sin(angle)
	return Vector(self[1]*c - self[2]*s, self[1]*s + self[2]*c)
end


function Vector:normalize( )
	local mag = self:mag()
	return Vector( self[1] / mag, self[2] / mag )
end

function Vector:angleDiff( vec )
	nv1 = Vector(self[1],self[2]):normalize()
	nv2 = Vector(vec[1],vec[2]):normalize()
 	local cosangle = math.acos( nv1[1]*nv2[1] + nv1[2]*nv2[2] )
	local sinangle = math.asin( nv1[1]*nv2[2] - nv1[2]*nv2[1] )

	if sinangle < 0 then
		return -cosangle
	end
	return cosangle
end

function Vector:distance( vec2 )
	return Vector( vec2[1]-self[1], vec2[2]-self[2]):mag()
end

function Vector:diff(dest)
	local destv = Vector( dest[1] - self[1], dest[2] - self[2] )
	local modul = destv:mag()
	if modul < 0.001 then
	  modul = 0.001
	end
	return Vector( destv[1]/modul, destv[2]/modul )
end

function Vector:add( ... )
	local res = Vector( self[1], self[2] )
	for i,vec in ipairs(arg) do
		res = Vector( res[1] + vec[1], res[2] + vec[2] )
	end
	return res
end

function Vector:smul( alpha )
	return Vector( self[1]*alpha, self[2]*alpha )
end

