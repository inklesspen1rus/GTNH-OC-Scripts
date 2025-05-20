-- https://computercraft.ru/topic/565-vec3-kod-dlya-raboty-s-3d-vektorami/

-- ********************************************************************************** --
-- **   3D Vector                                                                  ** --
-- **                                                                              ** --
-- **   Modified version of 2d vector from                                         ** --
-- **   https://github.com/vrld/hump/blob/master/vector.lua                        ** --
-- **                                                                              ** --
-- ********************************************************************************** --

local assert = assert
local sqrt, cos, sin, atan2 = math.sqrt, math.cos, math.sin, math.atan2

local vector = {}
vector.__index = vector

local function new(x,y,z)
    return setmetatable({x = x or 0, y = y or 0, z = z or 0}, vector)
end
local zero = new(0,0,0)

local function isvector(v)
    return type(v) == 'table' and type(v.x) == 'number' and type(v.y) == 'number' and type(v.z) == 'number'
end

function vector:clone()
    return new(self.x, self.y, self.z)
end

function vector:unpack()
    return self.x, self.y, self.z
end

function vector:__tostring()
    return "("..tonumber(self.x)..","..tonumber(self.y)..","..tonumber(self.z)..")"
end

function vector.__unm(a)
    return new(-a.x, -a.y, -a.z)
end

function vector.__add(a,b)
    assert(isvector(a) and isvector(b), "Add: wrong argument types (<vector> expected)")
    return new(a.x+b.x, a.y+b.y, a.z+b.z)
end

function vector.__sub(a,b)
    assert(isvector(a) and isvector(b), "Sub: wrong argument types (<vector> expected)")
    return new(a.x-b.x, a.y-b.y, a.z-b.z)
end

function vector.__mul(a,b)
    if type(a) == "number" then
    return new(a*b.x, a*b.y, a*b.z)
    elseif type(b) == "number" then
    return new(b*a.x, b*a.y, b*a.z)
    else
    assert(isvector(a) and isvector(b), "Mul: wrong argument types (<vector> or <number> expected)")
    return a.x*b.x + a.y*b.y + a.z*b.z
    end
end

function vector.__div(a,b)
    assert(isvector(a) and type(b) == "number", "wrong argument types (expected <vector> / <number>)")
    return new(a.x / b, a.y / b, a.z / b)
end

function vector.__eq(a,b)
    return a.x == b.x and a.y == b.y and a.z == b.z
end

function vector.__lt(a,b)
    return a.x < b.x and a.y < b.y and a.z < b.z
end

function vector.__le(a,b)
    return a.x <= b.x and a.y <= b.y and a.z <= b.z
end

function vector.permul(a,b)
    assert(isvector(a) and isvector(b), "permul: wrong argument types (<vector> expected)")
    return new(a.x*b.x, a.y*b.y, a.z*b.z)
end

function vector:len2()
    return self.x * self.x + self.y * self.y + self.z * self.z
end

function vector:len()
    return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function vector.dist(a, b)
    assert(isvector(a) and isvector(b), "dist: wrong argument types (<vector> expected)")
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z
    return sqrt(dx * dx + dy * dy + dz * dz)
end

function vector.dist2(a, b)
    assert(isvector(a) and isvector(b), "dist: wrong argument types (<vector> expected)")
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z
    return (dx * dx + dy * dy + dz * dz)
end

function vector:normalize_inplace()
    local l = self:len()
    if l > 0 then
    self.x, self.y, self.z = self.x / l, self.y / l, self.z / l
    end
    return self
end

function vector:normalized()
    return self:clone():normalize_inplace()
end

function vector:rotate_inplace_z(phi)
    local c, s = cos(phi), sin(phi)
    self.x, self.y = c * self.x - s * self.y, s * self.x + c * self.y
    return self
end  
function vector:rotate_inplace_x(phi)
    local c, s = cos(phi), sin(phi)
    self.y, self.z = c * self.y - s * self.z, s * self.y + c * self.z
    return self
end  
function vector:rotate_inplace_y(phi)
    local c, s = cos(phi), sin(phi)
    self.z, self.x = c * self.z - s * self.x, s * self.z + c * self.x
    return self
end
    
function vector:rotated_z(phi)
    local c, s = cos(phi), sin(phi)
    return new(c * self.x - s * self.y, s * self.x + c * self.y, self.z)
end  
function vector:rotated_x(phi)
    local c, s = cos(phi), sin(phi)
    return new(self.x, c * self.y - s * self.z, s * self.y + c * self.z)
end  
function vector:rotated_y(phi)
    local c, s = cos(phi), sin(phi)
    return new(s * self.z + c * self.x, self.y, c * self.z - s * self.x)
end

function vector:cross(v)
    assert(isvector(v), "cross: wrong argument types (<vector> expected)")
    return new(self.Y * v.Z - self.Z * v.Y,
                self.Z * v.X - self.X * v.Z,
                self.X * v.Y - self.Y * v.X)
end

-- ref.: http://blog.signalsondisplay.com/?p=336
function vector:trim_inplace(maxLen)
    local s = maxLen * maxLen / self:len2()
    s = (s > 1 and 1) or math.sqrt(s)
    self.x, self.y, self.z = self.x * s, self.y * s, self.z * s
    return self
end

function vector:trimmed(maxLen)
    return self:clone():trim_inplace(maxLen)
end


-- the module
return setmetatable({new = new, isvector = isvector, zero = zero},
{__call = function(_, ...) return new(...) end})