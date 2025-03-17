---@meta filesystem

local module = {}

---@class filesystem.file
local file = {}

function file:close() end

---@param n number Number of bytes to read
---@return string | nil, string
function file:read(n) end

---@param str string
---@return true | nil, string
function file:write(str) end

---@param whence 'set' | 'cur' | 'end'
---@param offset number
---@return number | nil, string
function file:seek(whence, offset) end

---@alias filesystem.openmode
---|>"r"
---| "rb"
---| "w"
---| "wb"
---| "a"
---| "ab"

--- Open a new file descriptor and returns its handle.
---
--- **It's recommended to use io.open** due to io.open's buffering
---@param path string
---@param mode? filesystem.openmode
---@return filesystem.file | nil, string
function module.open(path, mode) end

---@param value boolean
function module.setAutorunEnabled(value) end

--- Convert path to canonical one
---
--- ```
--- /tmp/../bin/ls.lua -> /bin/ls.lua
--- /bin/./ls.lua -> /bin/ls.lua
--- ```
--- 
---@param path string
---@return string result Canoncal path
function module.canonical(path) end

--- Concatinate paths to canonical one
--- 
--- ```
--- /a + b = /a/b
--- /a/ + /b/ = /a/b
--- /a/../a/ + /b/. = /a/b
--- ```
---
---@param pathA string Absolute path
---@param pathB string Relative path.
---@vararg string Other paths
---@return string result Canoncal path
function module.concat(pathA, pathB, ...) end

---@param path string File path
---@return string name File name including extension
function module.name(path) end

--- Check if filesystem exists
--- 
---@param path string Filesystem entry path
---@return boolean
function module.exists(path) end

--- Return file size or 0 if isn't a file
---
---@param path string File path
---@return number size File size
function module.size(path) end

--- Check if path points to directory
--- 
---@param path string Filesystem entry path
---@return boolean isDirectory true if directory otherwise - false (is not dir or doesn't exist)
function module.isDirectory(path) end

--- Return iterator of directory entries
---
---@param path string Directory path
---@return fun(): string|nil, string
function module.list(path) end

--- Make directory
---@param path string
---@return boolean | nil, string
function module.makeDirectory(path) end

--- Remove file or directory
---
---@param path string
---@return boolean | nil, string
function module.remove(path) end

--- Copy file
---
---@param fromPath string
---@param toPath string
---@return boolean | nil, string
function module.copy(fromPath, toPath) end

return module