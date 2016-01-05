--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local exception = halimede.exception
local runtime = halimede.runtime


local function determineSetfenvFunction()
	local setfenvFunction
	if type.hasGlobalOfTypeTableOrUserdata('setfenv') then
		return setfenv
	elseif type.hasPackageChildFieldOfTypeFunctionOrCall('debug', 'setfenv') then
		return debug.setfenv
	else
		return nil
	end
end

local function determineLoadFunction(runtime, setfenvFunction)
	-- loadstring is not in Lua 5.2/5.3
	-- loadstring is an alias to load in LuaJIT, but seems not to have reference equality, sadly, hence this detection
	if type.hasGlobalOfTypeFunctionOrCall('load') and runtime.isLuaJit then
		return load
	elseif type.hasGlobalOfTypeFunctionOrCall('loadstring') and runtime.isLuaJit then
		return loadstring
	elseif type.hasGlobalOfTypeFunctionOrCall('load') and runtime.isLanguageLevelMoreModernThan(runtime.Lua51) then
		return load
	end

	local setfenvFunction = determineSetfenvFunction()

	if type.hasGlobalOfTypeFunctionOrCall('loadstring') and setfenvFunction ~= nil then
		return function(chunkString, chunkName, mode, environment)
			if mode ~= 't' then
				exception.throw("Unsupported mode '%s'", mode)
			end
			local chunk, errorMessage = loadstring(chunkString, chunkName)
			if chunk ~= nil then
				setfenvFunction(chunk, environment)
			end
			return chunk, errorMessage
		end
	end

	exception.throw("Can not load %s '%s' because a modern load() or older loadstring()/setfenv()/debug.setfenv() aren't available", description, origin)
end

assert.globalTypeIsFunctionOrCall('pcall')
local function execute(luaCodeString, description, origin, environment)
	assert.parameterTypeIsString('luaCodeString', luaCodeString)
	assert.parameterTypeIsString('description', description)
	assert.parameterTypeIsString('origin', origin)
	assert.parameterTypeIsTable('environment', environment)

	local loadFunction = determineLoadFunction(runtime, setfenvFunction)
	local chunk, errorMessage = loadFunction(luaCodeString, origin, 't', environment)

	if errorMessage ~= nil then
		exception.throw("Could not load %s '%s' because of error '%s'", description, origin, errorMessage)
	end

	local ok, resultOrError = pcall(chunk)
	if ok then
		return resultOrError
	end
	exception.throw("Could not run %s '%s' because of error '%s'", description, origin, resultOrError)
end

halimede.modulefunction(execute)
