--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local type = halimede.type
local assert = halimede.assert
local exception = require('halimede.exception')


assert.globalTableHasChieldFieldOfTypeFunction('os', 'execute')
function module.execute(shellLanguage, ...)
	assert.parameterTypeIsTable(shellLanguage)
	
	local command = shellLanguage.toShellCommand(shellLanguage.silentPath, shellLanguage.silentPath, ...)
	
	-- Lua 5.1: returns an exit code
	-- Lua 5.2 / 5.3: returns true or nil, string ('exit' or 'signal'), exit/signal code
	local exitCodeOrBoolean, terminationKind, exitCode = os.execute(command)
	if type.isNil(exitCodeOrBoolean) then
		return false, terminationKind, exitCode, command
	elseif type.isBoolean(exitCodeOrBoolean) then
		return exitCodeOrBoolean, terminationKind, exitCode, command
	else
		return exitCodeOrBoolean == 0, 'exit', exitCodeOrBoolean, command
	end
end
local execute = module.execute

function module.executeSilentlyExpectingSuccess(shellLanguage, ...)
	local success, terminationKind, exitCode, command = execute(shellLanguage, ...)
	if not success then
		exception.throwWithLevelIncrement(1, 'Could not execute shell command [%s]', command)
	end
end
