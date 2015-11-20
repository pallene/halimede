--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = require('halimede.exception')
local runtime = require('halimede.runtime')

assert.globalTypeIsFunction('pcall')
function module.execute(luaCodeString, description, origin, environment)
	assert.parameterTypeIsString('luaCodeString', luaCodeString)
	assert.parameterTypeIsString('description', description)
	assert.parameterTypeIsString('origin', origin)
	assert.parameterTypeIsTable('environment', environment)
	
	-- Not needed by all logic branches, but needed on Lua 5.1 and whenever a modern load is not detected (a rare case)
	local setfenvFunction
	if setenv ~= nil then
		setfenvFunction = setfenv
	else
		if debug ~= nil and debug.setfenv ~= nil then
			setfenvFunction = debug.setfenv
		else
			setfenvFunction = nil
		end
	end
	
	-- loadstring is not in Lua 5.2/5.3
	-- loadstring is an alias to load in LuaJIT, but seems not to have reference equality, sadly, hence this detection
	local canUseModernLoad
	local loadingFunction
	if load ~= nil and runtime.isLuaJit then
		canUseModernLoad = true
		loadingFunction = load
	elseif loadstring ~= nil and runtime.isLuaJit then
		canUseModernLoad = true
		loadingFunction = loadstring
	elseif load ~= nil and runtime.isLanguageLevelMoreModernThan(runtime.Lua51) then
		canUseModernLoad = true
		loadingFunction = load
	elseif loadstring ~= nil and setfenvFunction ~= nil then
		canUseModernLoad = false
		loadingFunction = loadstring
	else
		exception.throw("Can not load %s '%s' because a modern load() or older loadstring()/setfenv()/debug.setfenv() aren't available", description, origin)
	end
	
	local chunkString = luaCodeString
	local chunkName = origin
	
	local chunk, errorMessage
	if canUseModernLoad then
		chunk, errorMessage = load(chunkString, chunkName, 't', environment)
	else
		chunk, errorMessage = loadstring(chunkString, chunkName)
		if chunk ~= nil then
			setfenvFunction(chunk, environment)
		end
	end
	
	if errorMessage ~= nil then
		exception.throw("Could not load %s '%s' because of error '%s'", description, origin, errorMessage)
	end
	
	local ok, resultOrError = pcall(chunk)
	if ok then
		return resultOrError
	end
	exception.throw("Could not run %s '%s' because of error '%s'", description, origin, resultOrError)
end
