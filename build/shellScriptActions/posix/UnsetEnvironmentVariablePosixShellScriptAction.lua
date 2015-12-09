--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local PosixShellLanguage = halimede.io.shellScript.ShellLanguage.Posix
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction


moduleclass('UnsetEnvironmentVariablePosixShellScriptAction', AbstractShellScriptAction)

function module:initialize()
	AbstractShellScriptAction.initialize(self)
end


assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'format')
function module:execute(shellScript, variableName)
	assert.parameterTypeIsString('variableName', variableName)
	
	-- Complexity is to cope with the mksh and pdksh shells, which don't like to unset something not set (when using set -u)
	local quotedVariableName = PosixShellLanguage:quoteArgument(variableName)
	shellScript:appendLinesToScript(("(unset %s) 1>/dev/null 2>/dev/null && unset %s"):format(quotedVariableName, quotedVariableName))
end
