--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction
local AbstractExportEnvironmentVariableShellScriptAction = halimede.build.shellScriptActions.AbstractExportEnvironmentVariableShellScriptAction
local ShellArgument = halimede.io.shellScript.ShellArgument


halimede.moduleclass('UnsetEnvironmentVariablePosixShellScriptAction', AbstractShellScriptAction)

local escapedArgument__program_unset = ShellArgument:new('_program_unset')

function module:initialize()
	AbstractShellScriptAction.initialize(self)
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'format')
function module:_execute(shellScript, builder, variableName)
	assert.parameterTypeIsString('variableName', variableName)
	
	AbstractExportEnvironmentVariableShellScriptAction.validateEnvironmentVariableName(variableName)

	-- Relies on function definition _program_unset() in StartPosixShellScriptAction
	shellScript:appendCommandLineToScript(escapedArgument__program_unset, ShellArgument:new(variableName))
end
