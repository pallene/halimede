--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction
local CommentCmdShellScriptAction = require.sibling.CommentCmdShellScriptAction
local UnsetEnvironmentVariableCmdShellScriptAction = require.sibling.UnsetEnvironmentVariableCmdShellScriptAction
local ExportEnvironmentVariableCmdShellScriptAction = require.sibling.ExportEnvironmentVariableCmdShellScriptAction
local CmdShellLanguage = halimede.io.shellScript.ShellLanguage.Cmd


halimede.moduleclass('StartScriptCmdShellScriptAction', AbstractShellScriptAction)

local environmentVariablesToUnset = {
}

local environmentVariablesToExport = {
}

function module:initialize()
	AbstractStartShellScriptAction.initialize(self, CommentCmdShellScriptAction, UnsetEnvironmentVariableCmdShellScriptAction, ExportEnvironmentVariableCmdShellScriptAction, environmentVariablesToUnset, environmentVariablesToExport,
		'@ECHO OFF',
		'SETLOCAL EnableExtensions',
		'SETLOCAL',
		'SET PATHEXT="' .. CmdShellLanguage.DefaultPathExt .. '"',
		'SET HALIMEDE_SHELLSCRIPT_ABSOLUTE_FOLDER_PATH="%~dp0"',
		'SET HALIMEDE_SHELLSCRIPT_ORIGINAL_WORKING_DIRECTORY="%CD%"',
		'CD /D "%HALIMEDE_SHELLSCRIPT_ABSOLUTE_FOLDER_PATH%"'
	)
end
