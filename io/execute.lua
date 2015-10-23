--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = require('halimede.exception')
local toShellCommand = requireSibling('toShellCommand').toShellCommand


assert.globalTableHasChieldFieldOfTypeFunction('os', 'execute')
function module.execute(shellLanguage, ...)
	assert.parameterTypeIsFunctionOrCall(shellLanguage)
	
	local command = shellLanguage.toShellCommand(...)
	return os.execute(command)
end

assert.globalTableHasChieldFieldOfTypeFunction('os', 'execute')
function module.shellIsAvailable()
	return os.execute()
end

assert.globalTableHasChieldFieldOfTypeFunction('os', 'execute')
function module.commandIsAvailable(shellLanguage)
	
	-- Walk the variable 'PATH' (can be misnamed on Windows as both path and Path)
	-- Split on : (POSIX) or ; (Windows)
	
	-- 1>/dev/null 2>/dev/null
	--
	--
	-- 1 > NUL 2 > NUL
end
