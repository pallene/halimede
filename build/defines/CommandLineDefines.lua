--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('middleclass')
local tabelize = require('halimede.table.tabelize').tabelize
local Defines = requireSibling('Defines')


local CommandLineDefines = class('CommandLineDefines', Defines)

function CommandLineDefines:initialize(doNotPredefineSystemOrCompilerDriverMacros, ...)
	assert.parameterTypeIsBoolean(doNotPredefineSystemOrCompilerDriverMacros)
	
	Defines.initialize(self, ...)
	
	self.doNotPredefineSystemOrCompilerDriverMacros = doNotPredefineSystemOrCompilerDriverMacros
end

assert.globalTypeIsFunction('pairs', 'ipairs')
function CommandLineDefines:appendToCommandLineArguments(arguments)
	assert.parameterTypeIsTable(arguments)
	
	if self.doNotPredefineSystemOrCompilerDriverMacros then
		arguments:insert('-undef')
	end
	
	for defineName, _ in ipairs(self.explicitlyUndefine) do
		arguments:insert('-U' .. defineName)
	end
	for defineName, defineValue in pairs(self.defines) do
		arguments:insert('-D' .. defineName .. '=' .. defineValue)
	end
	
	return arguments
end
