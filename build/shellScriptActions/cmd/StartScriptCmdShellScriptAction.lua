--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = halimede.exception
local Path = halimede.io.paths.Path
local UnsetEnvironmentVariableCmdShellScriptAction = require.sibling('UnsetEnvironmentVariableCmdShellScriptAction')
local ExportEnvironmentVariableCmdShellScriptAction = require.sibling('ExportEnvironmentVariableCmdShellScriptAction')
local ChangeDirectoryCmdShellScriptAction = require.sibling('ChangeDirectoryCmdShellScriptAction')
local AbstractCmdShellScriptAction = require.sibling('AbstractCmdShellScriptAction')
local RemoveRecursivelyWithForceCmdShellScriptAction = require.sibling('RemoveRecursivelyWithForceCmdShellScriptAction')
local MakeDirectoryRecursivelyCmdShellScriptAction = require.sibling('MakeDirectoryRecursivelyCmdShellScriptAction')


moduleclass('StartScriptCmdShellScriptAction', AbstractCmdShellScriptAction)

local environmentVariablesToUnset = {
}

local environmentVariablesToExport = {
}

function module:initialize(shellScript)
	AbstractCmdShellScriptAction.initialize(self, shellScript)
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:execute(recipeFolderPath, sourceFolderRelativePath, buildFolderRelativePath, patchFolderRelativePath)
	assert.parameterTypeIsInstanceOf('recipeFolderPath', recipeFolderPath, Path)
	assert.parameterTypeIsInstanceOf('sourceFolderRelativePath', sourceFolderRelativePath, Path)
	assert.parameterTypeIsInstanceOf('buildFolderRelativePath', buildFolderRelativePath, Path)
	assert.parameterTypeIsInstanceOf('patchFolderRelativePath', patchFolderRelativePath, Path)
	
	recipeFolderPath:assertIsFolderPath('recipeFolderPath')
	recipeFolderPath:assertIsEffectivelyAbsolute('recipeFolderPath')
	
	sourceFolderRelativePath:assertIsFolderPath('sourceFolderRelativePath')
	sourceFolderRelativePath:assertIsRelative('sourceFolderRelativePath')
	
	buildFolderRelativePath:assertIsFolderPath('buildFolderRelativePath')
	buildFolderRelativePath:assertIsRelative('buildFolderRelativePath')
	
	patchFolderRelativePath:assertIsFolderPath('patchFolderRelativePath')
	patchFolderRelativePath:assertIsRelative('patchFolderRelativePath')

	self:_appendLinesToScript(
		'@ECHO OFF',
		'SETLOCAL EnableExtensions',
		'SETLOCAL',
		'CD /D "%~dp0"'
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
	changeDirectoryShellScriptAction:execute(recipeFolderPath)
	
	local removeRecursivelyWithForceShellScriptAction = RemoveRecursivelyWithForceCmdShellScriptAction:new(self.shellScript)
	removeRecursivelyWithForceShellScriptAction:execute(buildFolderRelativePath)
	
	local makeDirectoryRecursivelyShellScriptAction = MakeDirectoryRecursivelyCmdShellScriptAction:new(self.shellScript)
	makeDirectoryRecursivelyShellScriptAction:execute(buildFolderRelativePath, '0755')
	
	changeDirectoryShellScriptAction:execute(buildFolderRelativePath)
end
