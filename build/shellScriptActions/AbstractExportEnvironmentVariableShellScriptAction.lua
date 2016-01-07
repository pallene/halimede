--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local isString = halimede.type.isString
local exception = halimede.exception
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction
local ShellArgument = halimede.io.shellScript.ShellArgument


halimede.moduleclass('AbstractExportEnvironmentVariableShellScriptAction', AbstractShellScriptAction)

AbstractExportEnvironmentVariableShellScriptAction.static.validateEnvironmentVariableName = function(variableName)
	if variableName:find('[A-Z_][A-Z0-9_]+') ~= 1 then
		exception.throw("Environment variableName must be A-Z, _ or 0-9, and start with A-Z or _ for maximum compatibility between shells")
	end
end

function module:initialize(escapedArgument)
	assert.parameterTypeIsString('escapedArgument', escapedArgument)
	
	AbstractShellScriptAction.initialize(self)
	
	self.escapedArgument = ShellArgument:new(escapedArgument)
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'find')
function module:_execute(shellScript, builder, variableName, variableValue)
	assert.parameterTypeIsString('variableName', variableName)
	
	AbstractExportEnvironmentVariableShellScriptAction.validateEnvironmentVariableName(variableName)
	
	local prefix = variableName .. '='
	local setting
	if isString(variableValue) then
		setting = ShellArgument:new(prefix .. shellScript.shellLanguage:escapeToShellSafeString(variableValue))
	elseif isInstanceOf(variableValue, ShellPath) or isInstanceOf(variableValue, Path)
		setting = variableValue:escapeToShellArgument(true, shellScript.shellLanguage):prepend(prefix)
	else
		setting = variableValue:prepend(prefix)
	end
	
	shellScript:appendCommandLineToScript(self.escapedArgument, setting)
end
