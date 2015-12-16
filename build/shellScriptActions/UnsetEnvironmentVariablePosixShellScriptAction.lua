--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction


moduleclass('UnsetEnvironmentVariablePosixShellScriptAction', AbstractShellScriptAction)

function module:initialize()
	AbstractShellScriptAction.initialize(self)
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'format')
function module:_execute(shellScript, builder, variableName)
	assert.parameterTypeIsString('variableName', variableName)
	
	-- Relies on function definition _program_unset() in StartPosixShellScriptAction
	shellScript:appendCommandLineToScript('_program_unset', variableName)
end
