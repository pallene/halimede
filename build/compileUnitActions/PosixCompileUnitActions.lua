--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local CompileUnitActions = requireSibling('CompileUnitActions')
moduleclass('PosixCompileUnitActions', CompileUnitActions)

local halimede = require('halimede')
local assert = halimede.assert
local ShellLanguage = require('halimede.io.shellScript.ShellLanguage')
local UnsetEnvironmentVariablePosixShellScriptAction = require('halimede.build.shellScriptActions.posix.UnsetEnvironmentVariablePosixShellScriptAction')
local ExportEnvironmentVariablePosixShellScriptAction = require('halimede.build.shellScriptActions.posix.ExportEnvironmentVariablePosixShellScriptAction')


local environmentVariablesToUnsetAtBuildScriptStart = {
	'CDPATH',
	'BASH_ENV',
	'ENV',
	'MAIL',
	'MAILPATH'
}

local environmentVariablesToExportAtBuildScriptStart = {
	LC_ALL = 'C',
	LC_CTYPE = 'C',
	LC_MESSAGES = 'C',
	LANGUAGE = 'C',
	LANG = 'C'
}

function module:initialize(sourcePath, sysrootPath, toolchain)
	AbstractCompileUnitActions.initialise(self, ShellLanguage.POSIX, sourcePath, sysrootPath, toolchain)
end

assert.globalTypeIsFunction('ipairs')
function module:_initialBuildScript()
	-- Can't use a multiline string because the new line terminator is wrong if this file is edited by some Windows programs
	
	local ifsValue=' \t\n'
	self:_appendLinesToScript(
		'#!/usr/bin/env sh',
		'set -e',
		'set -u',
		'set -f',
		'(set -o posix) 1>/dev/null 2>/dev/null && set -o posix',  -- For bash
		'export DUALCASE=1',  -- For MKS Shell
		'if [ -n "${ZSH_VERSION+set}" ]; then',  -- For zsh
		'    emulate sh',
		'    NULLCMD=:',
		'    # Pre-4.2 versions of Zsh (superseded as of 2004-03-19) do word splitting on ${1+"$[@]"}, which is not wanted',
		[[    alias -g '${1+"$[@]"}'='"$[@]"']],
		'    setopt NO_GLOB_SUBST',
		'fi',
		'IFS="' .. ifsValue .. '"'
	)
	
	local unsetEnvironmentVariableAction = UnsetEnvironmentVariablePosixShellScriptAction:new()
	for _, environmentVariableName in ipairs(environmentVariablesToUnsetAtBuildScriptStart) do
		unsetEnvironmentVariableAction:execute(environmentVariableName)
	end
	
	local exportEnvironmentVariableAction = ExportEnvironmentVariablePosixShellScriptAction:new()
	for environmentVariableName, environmentVariableValue in pairs(environmentVariablesToExportAtBuildScriptStart) do
		exportEnvironmentVariableAction:execute(environmentVariableName, environmentVariableValue)
	end
end

function module:_finalBuildScript()
end
