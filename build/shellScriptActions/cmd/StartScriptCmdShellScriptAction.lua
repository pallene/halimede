--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction
local UnsetEnvironmentVariableCmdShellScriptAction = require.sibling('UnsetEnvironmentVariableCmdShellScriptAction')
local ExportEnvironmentVariableCmdShellScriptAction = require.sibling('ExportEnvironmentVariableCmdShellScriptAction')
local ChangeDirectoryCmdShellScriptAction = require.sibling('ChangeDirectoryCmdShellScriptAction')
local RemoveRecursivelyWithForceCmdShellScriptAction = require.sibling('RemoveRecursivelyWithForceCmdShellScriptAction')
local MakeDirectoryRecursivelyCmdShellScriptAction = require.sibling('MakeDirectoryRecursivelyCmdShellScriptAction')
local Path = halimede.io.paths.Path


moduleclass('StartScriptCmdShellScriptAction', AbstractShellScriptAction)

local environmentVariablesToUnset = {
}

local environmentVariablesToExport = {
}

function module:initialize()
	AbstractStartShellScriptAction.initialize(self, UnsetEnvironmentVariableCmdShellScriptAction, ExportEnvironmentVariableCmdShellScriptAction, environmentVariablesToUnset, environmentVariablesToExport, 
		'@ECHO OFF',
		'SETLOCAL EnableExtensions',
		'SETLOCAL',
		'CD /D "%~dp0"'
	)
end
