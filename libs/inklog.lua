local module = {}

module.TRACE = 00
module.DEBUG = 10
module.INFO = 20
module.WARN = 30
module.ERROR = 40

---@alias inklog.FormattableMessage string | fun(...): string
---@alias inklog.Context table<string, string>

---@param message inklog.FormattableMessage
---@param ... any
---@return string
function module.format(message, ...)
    local t = type(message)
    if t == "string" then
        return string.format(message, ...)
    elseif t == "function" then
        return message(...)
    end
    error("Unable to format unknown type: " .. t)
end

---@class inklog.Logger
local BaseLogger = {}

---@param level integer
---@param message inklog.FormattableMessage
---@param ... any
function BaseLogger:log(level, message, ...) end

---@param message inklog.FormattableMessage
---@param ... any
function BaseLogger:info(message, ...)
    self:log(module.INFO, message, ...)
end

---@param message inklog.FormattableMessage
---@param ... any
function BaseLogger:error(message, ...)
    self:log(module.ERROR, message, ...)
end

---@param message inklog.FormattableMessage
---@param ... any
function BaseLogger:trace(message, ...)
    self:log(module.TRACE, message, ...)
end

---@param message inklog.FormattableMessage
---@param ... any
function BaseLogger:debug(message, ...)
    self:log(module.TRACE, message, ...)
end

---@class inklog.ILogProvider
---@field log fun(context: inklog.Context, level: integer, message: inklog.FormattableMessage, ...: any)

---@class inklog.ScopeLogger: inklog.Logger
---@field private __provider inklog.ILogProvider
---@field private __context inklog.Context
local ScopeLogger = setmetatable({}, BaseLogger)

function ScopeLogger:log(level, message, ...)
    self.__provider.log(self.__context, level, message, ...)
end

---@param provider inklog.ILogProvider
---@return inklog.ScopeLogger
function ScopeLogger.new(provider)
    return setmetatable({
        __provider = provider,
        __context = {}
    }, BaseLogger)
end

---@param context? table
---@return inklog.ScopeLogger
function ScopeLogger:createScope(context)
    return setmetatable({
        __context = setmetatable(context or {}, self.__context)
    }, self)
end

---@class inklog.BaseLogProvider: inklog.ILogProvider
---@field __filters? (fun(context: table, level: integer): boolean)[]
local BaseLogProvider = {}
module.BaseLogProvider = BaseLogProvider

---@param filter fun(context: table, level: integer): boolean
function BaseLogProvider:addFilter(filter)
    self.__filters = self.__filters or {}
    table.insert(self.__filters or {}, filter)
end

---@param context inklog.Context
---@param level any
---@param message any
---@param ... unknown
function BaseLogProvider:log(context, level, message, ...)
    for _, value in ipairs(self.__filters) do
        if not value(context, level) then return end
    end
    self:_log(context, level, message, ...)
end

---@protected
---@param context inklog.Context
---@param level integer
---@param message inklog.FormattableMessage
---@param ... unknown
function BaseLogProvider:_log(context, level, message, ...) end

---@class inklog.FunLogProvider: inklog.BaseLogProvider
---@field private __appender fun(context: inklog.Context, level: integer, message: inklog.FormattableMessage, ...: any)
local FunLogProvider = setmetatable({}, BaseLogProvider)

---@param appender fun(context: table, level: integer, message: inklog.FormattableMessage, ...: any)
function FunLogProvider.new(appender)
    return setmetatable({
        __appender = appender
    }, FunLogProvider)
end

function FunLogProvider:_log(context, level, message, ...)
    self.__appender(context, level, message, ...)
end

---@class inklog.CompositeLogProvider: inklog.ILogProvider
---@field private __providers? inklog.ILogProvider[]
local CompositeLogProvider = setmetatable({}, BaseLogProvider)
module.CompositeLogProvider = CompositeLogProvider

function CompositeLogProvider.new()
    return setmetatable({}, CompositeLogProvider)
end

function CompositeLogProvider:addProvider(provider)
    self.__providers = self.__providers or {}
    table.insert(self.__providers, provider)
end

---@param context inklog.Context
---@param level any
---@param message any
---@param ... unknown
function CompositeLogProvider:_log(context, level, message, ...)
    for _, value in ipairs(self.__providers) do
        value.log(context, level, message, ...)
    end
end

return module