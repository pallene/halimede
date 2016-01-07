--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction


halimede.moduleclass('AbstractStartShellScriptAction', AbstractShellScriptAction)

function module:initialize(commentShellScriptActionClass, unsetEnvironmentVariableShellScriptActionClass, exportEnvironmentVariableShellScriptActionClass, environmentVariablesToUnset, environmentVariablesToExport)
	assert.parameterTypeIsTable('commentShellScriptActionClass', commentShellScriptActionClass)
	assert.parameterTypeIsTable('environmentVariablesToUnset', environmentVariablesToUnset)
	assert.parameterTypeIsTable('environmentVariablesToExport', environmentVariablesToExport)

	AbstractShellScriptAction.initialize(self)

	self.commentShellScriptAction = commentShellScriptActionClass:new()
	self.unsetEnvironmentVariableShellScriptAction = unsetEnvironmentVariableShellScriptActionClass:new()
	self.exportEnvironmentVariableShellScriptAction = exportEnvironmentVariableShellScriptActionClass:new()
	self.environmentVariablesToUnset = environmentVariablesToUnset
	self.environmentVariablesToExport = environmentVariablesToExport
end

assert.globalTypeIsFunctionOrCall('ipairs', 'pairs')
function module:_execute(shellScript, builder, useHomebrew)
	shellScript:appendLines(self:_initialLinesForScript(useHomebrew))

	self.commentShellScriptAction:execute(shellScript, builder, 'Unsetting unreliable and polluting environment variables')
	for _, environmentVariableName in ipairs(self.environmentVariablesToUnset) do
		self.unsetEnvironmentVariableShellScriptAction:execute(shellScript, builder, environmentVariableName)
	end

	self.commentShellScriptAction:execute(shellScript, builder, 'Exporting useful environment variables')
	for environmentVariableName, environmentVariableValue in pairs(self.environmentVariablesToExport) do
		self.exportEnvironmentVariableShellScriptAction:execute(shellScript, builder, environmentVariableName, environmentVariableValue)
	end
end

--noinspection UnusedDef
function module:_initialLinesForScript(useHomebrew)
	exception.throw('Abstract Method')
end
