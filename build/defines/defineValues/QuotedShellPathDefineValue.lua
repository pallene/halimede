--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractDefineValue = halimede.build.defines.defineValues.AbstractDefineValue
local ShellPath = halimede.io.shellScript.ShellPath
local ShellArgument = halimede.io.shellScript.ShellArgument


halimede.moduleclass('QuotedShellPathDefineValue', AbstractDefineValue)

function module:initialize(shellPath)
	assert.parameterTypeIsInstanceOf('shellPath', shellPath, ShellPath)
	
	AbstractDefineValue.initialize(self)
	
	self.shellPath = shellPath
end

function module:_toShellArgument(shellLanguage)
	local escapedDoubleQuote = shellLanguage:escapeToShellSafeString('"')
	
	local argument = self.shellPath:escapeToShellArgument(true, shellLanguage).argument
	
	return ShellArgument:new(escapedDoubleQuote .. argument .. escapedDoubleQuote)
end