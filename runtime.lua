--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local type = halimede.type
local exception = halimede.exception


assert.globalTypeIsFunctionOrCall('setmetatable')
local knownLanguageLevelMappings = setmetatable({
	['Lua 5.0'] = 1,
	['Lua 5.1'] = 2,
	['Lua 5.2'] = 3,
	['Lua 5.3'] = 4,
	}, {__index = function(_, languageLevel)
		exception.throwWithLevelIncrement(1, "There is no knowledge of language level '%s'", languageLevel)
	end})

local defaultLanguageLevel = 'Lua 5.1'

assert.globalTypeIsFunctionOrCall('tonumber')
local function detectRuntime()
	local virtualMachine
	if type.hasPackageChildFieldOfTypeString('jit', 'version') then
		-- eg 'LuaJIT 2.0.4'
		virtualMachine = jit.version
	elseif type.hasGlobalOfTypeString('_VERSION') then
		virtualMachine = _VERSION
	else
		virtualMachine = defaultLanguageLevel
	end

	local languageLevel
	if type.hasGlobalOfTypeString('_VERSION') then
		languageLevel = _VERSION
	else
		languageLevel = defaultLanguageLevel
	end

	-- Not necessarily true
	local isLuaJit = type.hasGlobalOfTypeTableOrUserdata('jit')

	return {
		Lua51 = 'Lua 5.1',
		virtualMachine = virtualMachine,
		languageLevel = languageLevel,
		isLuaJit = isLuaJit,
		isLanguageLevelMoreModernThan = function(olderLanguageLevel)
			return knownLanguageLevelMappings[languageLevel] > knownLanguageLevelMappings[olderLanguageLevel]
		end
	}
end

assert.globalTypeIsFunctionOrCall('pairs')
for key, value in pairs(detectRuntime()) do
	module[key] = value
end
