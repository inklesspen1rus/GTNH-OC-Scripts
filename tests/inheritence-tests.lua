---@class TestBaseObject
---@field a integer
local TestBaseObject = {}

---@class TestBaseObject.ConstructorParams
---@field a integer

---@param o TestBaseObject.ConstructorParams
---@return TestBaseObject
function TestBaseObject:new(o)
    setmetatable(o, self)
    self.__index = self
    ---@diagnostic disable-next-line: return-type-mismatch
    return o
end

function TestBaseObject:hi()
    print('Hi from TestBaseObject')
end

function TestBaseObject:dispose()
    print('Disposed from TestBaseObject')
end


---@diagnostic disable-next-line: missing-fields
local TestDerivedObject = setmetatable({}, {__index=TestBaseObject})

function TestDerivedObject:dispose()
    print('Disposed from TestDerivedObject ... ' .. self.a)
    TestBaseObject.dispose(self)
end

---@diagnostic disable-next-line: missing-fields
local TestDerived2Object = setmetatable({}, {__index=TestDerivedObject})

function TestDerived2Object:dispose()
    print('Disposed from TestDerived2Object ... ' .. self.a)
    TestDerivedObject.dispose(self)
end


for k, v in pairs(TestDerived2Object) do print(k,v) end

local o = TestDerivedObject:new({ a = 2 })
o:hi()
o:hi()
o:hi()
o:dispose()
local o = TestDerived2Object:new({ a = 2 })
o:hi()
o:hi()
o:hi()
o:dispose()
local o = TestDerived2Object:new({ a = 2 })
o:hi()
o:hi()
o:hi()
o:dispose()

print(o.a)

