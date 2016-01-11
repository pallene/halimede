--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception
local CompilerDriverArguments = halimede.build.toolchain.CompilerDriverArguments
local ShellLanguage = halimede.io.shellScript.ShellLanguage


halimede.moduleclass('AbstractDefineValue')

function module:initialize()
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'isEmpty')
function module:toShellArgument(prepend, shellLanguage)
	assert.parameterTypeIsString('prepend', prepend)
	assert.parameterTypeIsInstanceOf('shellLanguage', shellLanguage, ShellLanguage)
	
	local shellArgument = self:_toShellArgument(shellLanguage)
	if prepend:isEmpty() then
		return shellArgument
	end
	
	local escapedPrepend = shellLanguage:escapeToShellSafeString(prepend)
	return shellArgument:prepend(escapedPrepend)
end

function module:_toShellArgument(shellLanguage)
	exception.throw('Abstract Method')
end
