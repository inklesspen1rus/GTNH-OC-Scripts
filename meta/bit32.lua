---@meta bit32

local module = {}

--- Returns a boolean signaling whether the bitwise and of its operands is different from zero. 
---@param ... integer
---@return boolean 
function module.btest(...) end

--- Returns the bitwise exclusive or of its operands. 
---@param ... integer
---@return integer 
function module.bxor(...) end

--- Returns the bitwise and of its operands.
---@param ... integer
---@return integer 
function module.band(...) end

--- Returns the bitwise or of its operands. 
---@param ... integer
---@return integer 
function module.bor(...) end

--- Returns the unsigned number formed by the bits field to field + width - 1 from n. Bits are numbered from 0 (least significant) to 31 (most significant). All accessed bits must be in the range [0, 31].
---
--- The default for width is 1. 
---@param n integer
---@param field integer
---@param width? integer
---@return integer 
function module.extract(n, field, width) end

--- Returns a copy of n with the bits field to field + width - 1 replaced by the value v. See bit32.extract for details about field and width. 
---@param n integer
---@param v integer
---@param field integer
---@param width? integer
---@return integer 
function module.replace(n, v, field, width) end

--- Returns the number x rotated disp bits to the left. The number disp may be any representable integer.
---
--- For any valid displacement, the following identity holds:
---
---`assert(bit32.lrotate(x, disp) == bit32.lrotate(x, disp % 32))`
---
--- In particular, negative displacements rotate to the right. 
---@param x integer
---@param disp integer
---@return integer 
function module.lrotate(x, disp) end

--- Returns the number x shifted disp bits to the left. The number disp may be any representable integer. Negative displacements shift to the right. In any direction, vacant bits are filled with zeros. In particular, displacements with absolute values higher than 31 result in zero (all bits are shifted out).
--- 
--- For positive displacements, the following equality holds:
--- 
--- `assert(bit32.lshift(b, disp) == (b * 2^disp) % 2^32)`
---@param x integer
---@param disp integer
---@return integer 
function module.lshift(x, disp) end

--- Returns the number x rotated disp bits to the right. The number disp may be any representable integer.
--- 
--- For any valid displacement, the following identity holds:
--- 
--- `assert(bit32.rrotate(x, disp) == bit32.rrotate(x, disp % 32))`
--- 
--- In particular, negative displacements rotate to the left. 
---@param x integer
---@param disp integer
---@return integer 
function module.rrotate(x, disp) end

--- Returns the number x shifted disp bits to the right. The number disp may be any representable integer. Negative displacements shift to the left. In any direction, vacant bits are filled with zeros. In particular, displacements with absolute values higher than 31 result in zero (all bits are shifted out).
--- 
--- For positive displacements, the following equality holds:
--- 
--- `assert(bit32.rshift(b, disp) == math.floor(b % 2^32 / 2^disp))`
--- 
--- This shift operation is what is called logical shift. 
---@param x integer
---@param disp integer
---@return integer 
function module.rshift(x, disp) end

--- Returns the bitwise negation of x. For any integer x, the following identity holds:
---
--- `assert(bit32.bnot(x) == (-1 - x) % 2^32)`
---@param x integer
---@return integer 
function module.bnot(x) end

return module