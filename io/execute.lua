--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local type = halimede.type
local assert = halimede.assert
local tabelize = require('halimede.table.tabelize').tabelize
local exception = require('halimede.exception')
local shellLanguage = require('halimede.io.ShellLanguage').Default


module.silenced = shellLanguage.silenced
module.noRedirection = false  -- Bizarre but works

assert.globalTableHasChieldFieldOfTypeFunction('os', 'execute')
function module.execute(standardIn, standardOut, standardError, ...)
	
	local arguments = tabelize({...})
	if standardIn then
		arguments:insert(shellLanguage.redirectInput(standardIn))
	end
	if standardOut then
		arguments:insert(shellLanguage.redirectOutput(standardOut))
	end
	if standardError then
		arguments:insert(shellLanguage.redirectOutput(standardError))
	end
	
	local command = shellLanguage.toShellCommand(...)
	
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

function module.executeExpectingSuccess(standardIn, standardOut, standardError, ...)
	local success, terminationKind, exitCode, command = execute(...)
	if not success then
		exception.throw("Could not execute shell command, returned exitCode '%s' for command [%s]", exitCode command)
	end
end
