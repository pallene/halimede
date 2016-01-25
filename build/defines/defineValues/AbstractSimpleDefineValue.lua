--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractDefineValue = halimede.build.defines.defineValues.AbstractDefineValue
local ShellArgument = halimede.io.shellScript.ShellArgument


halimede.moduleclass('AbstractSimpleDefineValue', AbstractDefineValue)

function module:initialize(value)
	assert.parameterTypeIsString('value', value)
	
	self.value = value
end

function module:_toShellArgument(shellLanguage)
	return ShellArgument:new(shellLanguage:escapeToShellSafeString(self.value))
end