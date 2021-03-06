--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local type = halimede.type
local isNotTable = type.isNotTable
local exception = halimede.exception
local Path = halimede.io.paths.Path
local executeFromFile = halimede.luacode.executeFromFile


assert.globalTypeIsFunctionOrCall('setmetatable')
local function wrapWithReadOnlyProxy(object)
	if isNotTable(object) then
		return object
	end

	return setmetatable({}, {
		__index = function(_, key)
			return wrapWithReadOnlyProxy(object[key])
		end,
		__newindex = function(_, key, value)
			exception.throwWithLevelIncrement(1, "Can not set field '%s' to value '%s'", key, value)
		end
	})
end

assert.globalTypeIsFunctionOrCall('setmetatable')
local function wrapWithReadOnlyProxyButCanAddFieldsToProxy(object)
	if isNotTable(object) then
		return object
	end

	local proxy = {}
	return setmetatable(proxy, {
		__index = function(_, key)
			local value = proxy[key]
			if value then
				return value
			end
			return wrapWithReadOnlyProxy(object[key])
		end,
		__newindex = function(_, key, value)
			proxy[key] = value
		end
	})
end

-- An inefficient multiple inheritance
assert.globalTypeIsFunctionOrCall('setmetatable')
local function wrapWithMultipleInheritanceProxy(initialState, ...)
	assert.parameterTypeIsString('initialState', initialState)

	local parents = {...}

	local proxy = initialState
	return setmetatable(proxy, {
		__index = function(_, key)
			for index = 1, #parents do
				local value = parents[index][key]
				if value ~= nil then
					return value
				end
			end
			return nil
		end,
		__newindex = function(_, key, value)
			proxy[key] = value
		end
	})
end

-- http://lua-users.org/wiki/SandBoxes
assert.globalTypeIsFunctionOrCall('assert', 'error', 'ipairs', 'next', 'pairs', 'pcall', 'tonumber', 'tostring', 'type', 'unpack', 'xpcall')
assert.globalTypeIsString('_VERSION')
assert.globalTypeIsTable('coroutine', 'string', 'table', 'math', 'os')
module.sandboxEnvironmentToPreserve = {
	assert = assert,
	error = error,
	ipairs = ipairs,
	next = next,
	pairs = pairs,
	pcall = pcall,
	tonumber = tonumber,
	tostring = tostring,
	type = type,
	unpack = unpack,
	_VERSION = _VERSION,
	xpcall = xpcall,
	coroutine = {
		create = coroutine.create,
		resume = coroutine.resume,
		running = coroutine.running,
		status = coroutine.status,
		wrap = coroutine.wrap
		--,yield = coroutine.yield
	},
	string = {
		byte = string.byte,
		char = string.char,
		find = string.find,
		format = string.format,
		gmatch = string.gmatch,
		gsub = string.gsub,
		len = string.len,
		lower = string.lower,
		match = string.match,
		rep = string.rep,
		reverse = string.reverse,
		sub = string.sub,
		upper = string.upper
	},
	table = {
		concat = table.concat,
		insert = table.insert,
		remove = table.remove,
		sort = table.sort
	},
	math = {
		abs = math.abs,
		acos = math.acos,
		asin = math.asin,
		atan = math.atan,
		atan2 = math.atan2,
		ceil = math.ceil,
		cos = math.cos,
		cosh = math.cosh,
		deg = math.deg,
		exp = math.exp,
		floor = math.floor,
		fmod = math.fmod,
		frexp = math.frexp,
		huge = math.huge,
		ldexp = math.ldexp,
		log = math.log,
		log10 = math.log10,
		max = math.max,
		min = math.min,
		modf = math.modf,
		pi = math.pi,
		pow = math.pow,
		rad = math.rad,
		random = math.random,
		sin = math.sin,
		sinh = math.sinh,
		sqrt = math.sqrt,
		tan = math.tan,
		tanh = math.tanh
	},
	os = {
		clock = os.clock,
		date = os.date,-- Previously could crash in older Lua 5.1 versions
		difftime = os.difftime,
		time = os.time
	}
}

-- Can not mutate any globals or their fields, but can 'shadow' (overlay) globals and assign new ones
function module.load(fileDescription, filePath, sandboxEnvironmentToPreserve, defaultConfigurationToPreserve, mutableInitialEnvironmentState)
	assert.parameterTypeIsString('fileDescription', fileDescription)
	assert.parameterTypeIsInstanceOf('filePath', filePath, Path)
	assert.parameterTypeIsTable('sandboxEnvironmentToPreserve', sandboxEnvironmentToPreserve)
	assert.parameterTypeIsTable('defaultConfigurationToPreserve', defaultConfigurationToPreserve)
	assert.parameterTypeIsTable('mutableInitialEnvironmentState', mutableInitialEnvironmentState)

	filePath:assertIsFilePath('filePath')

	local environment = wrapWithMultipleInheritanceProxy(mutableInitialEnvironmentState, wrapWithReadOnlyProxy(defaultConfigurationToPreserve), wrapWithReadOnlyProxy(sandboxEnvironmentToPreserve))
	return executeFromFile(fileDescription, filePath, environment), environment
end
