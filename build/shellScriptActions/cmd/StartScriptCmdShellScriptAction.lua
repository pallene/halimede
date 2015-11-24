--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractCmdShellScriptAction = requireSibling('AbstractCmdShellScriptAction')
moduleclass('StartScriptCmdShellScriptAction', AbstractCmdShellScriptAction)

local exception = halimede.exception
local Path = halimede.io.paths.Path')
local UnsetEnvironmentVariableCmdShellScriptAction = requireSibling('UnsetEnvironmentVariableCmdShellScriptAction')
local ExportEnvironmentVariableCmdShellScriptAction = requireSibling('ExportEnvironmentVariableCmdShellScriptAction')
local ChangeDirectoryCmdShellScriptAction = requireSibling('ChangeDirectoryCmdShellScriptAction')


local environmentVariablesToUnset = {
}

local environmentVariablesToExport = {
}

function module:initialize(shellScript)
	AbstractCmdShellScriptAction.initialize(self, shellScript)
end

assert.globalTypeIsFunction('ipairs')
function module:execute(sourcePath)
	assert.parameterTypeIsInstanceOf('sourcePath', sourcePath, Path)
	
	sourcePath:assertIsFolderPath('sourcePath')

	self:_appendLinesToScript(
		'@ECHO OFF',
		'SETLOCAL EnableExtensions'
	)
	
	local unsetEnvironmentVariableShellScriptAction = UnsetEnvironmentVariableCmdShellScriptAction:new(self.shellScript)
	for _, environmentVariableName in ipairs(environmentVariablesToUnset) do
		unsetEnvironmentVariableShellScriptAction:execute(environmentVariableName)
	end
	
	local exportEnvironmentVariableShellScriptAction = ExportEnvironmentVariableCmdShellScriptAction:new(self.shellScript)
	for environmentVariableName, environmentVariableValue in pairs(environmentVariablesToExport) do
		exportEnvironmentVariableShellScriptAction:execute(environmentVariableName, environmentVariableValue)
	end
	
	local changeDirectoryShellScriptAction = ChangeDirectoryCmdShellScriptAction:new(self.shellScript)
	changeDirectoryShellScriptAction:execute(sourcePath)
end
