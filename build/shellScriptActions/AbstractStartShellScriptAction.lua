--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Path = halimede.io.paths.Path
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction
local UnsetEnvironmentVariablePosixShellScriptAction = require.sibling('UnsetEnvironmentVariablePosixShellScriptAction')
local ExportEnvironmentVariablePosixShellScriptAction = require.sibling('ExportEnvironmentVariablePosixShellScriptAction')
local ChangeDirectoryPosixShellScriptAction = require.sibling('ChangeDirectoryPosixShellScriptAction')
local RemoveRecursivelyWithForcePosixShellScriptAction = require.sibling('RemoveRecursivelyWithForcePosixShellScriptAction')
local MakeDirectoryRecursivelyPosixShellScriptAction = require.sibling('MakeDirectoryRecursivelyPosixShellScriptAction')


moduleclass('AbstractStartShellScriptAction', AbstractShellScriptAction)

function module:initialize(unsetEnvironmentVariableShellScriptActionClass, exportEnvironmentVariableShellScriptActionClass, environmentVariablesToUnset, environmentVariablesToExport, ...)
	assert.parameterTypeIsTable('environmentVariablesToUnset', environmentVariablesToUnset)
	assert.parameterTypeIsTable('environmentVariablesToExport', environmentVariablesToExport)
	
	AbstractPosixShellScriptAction.initialize(self, shellScript)
	
	self.unsetEnvironmentVariableShellScriptAction = unsetEnvironmentVariableShellScriptActionClass:new()
	self.exportEnvironmentVariableShellScriptAction = exportEnvironmentVariableShellScriptActionClass:new()
	self.environmentVariablesToUnset = environmentVariablesToUnset
	self.environmentVariablesToExport = environmentVariablesToExport
	self.initialScriptLines = {...}
end

assert.globalTypeIsFunctionOrCall('unpack', 'ipairs', 'pairs')
function module:execute(shellScript)
	shellScript:appendLinesToScript(unpack(self.initialScriptLines))
	
	for _, environmentVariableName in ipairs(self.environmentVariablesToUnset) do
		self.unsetEnvironmentVariableShellScriptAction:execute(shellScript, environmentVariableName)
	end
	
	for environmentVariableName, environmentVariableValue in pairs(self.environmentVariablesToExport) do
		self.exportEnvironmentVariableShellScriptAction:execute(shellScript, environmentVariableName, environmentVariableValue)
	end
end
