--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractPosixShellScriptAction = requireSibling('AbstractPosixShellScriptAction')
moduleclass('StartScriptPosixShellScriptAction', AbstractPosixShellScriptAction)

local AbstractPath = require('halimede.io.paths.AbstractPath')
local UnsetEnvironmentVariablePosixShellScriptAction = requireSibling('UnsetEnvironmentVariablePosixShellScriptAction')
local ExportEnvironmentVariablePosixShellScriptAction = requireSibling('ExportEnvironmentVariablePosixShellScriptAction')
local ChangeDirectoryPosixShellScriptAction = requireSibling('ChangeDirectoryPosixShellScriptAction')


local environmentVariablesToUnset = {
	'CDPATH',
	'BASH_ENV',
	'ENV',
	'MAIL',
	'MAILPATH'
}

local environmentVariablesToExport = {
	LC_ALL = 'C',
	LC_CTYPE = 'C',
	LC_MESSAGES = 'C',
	LANGUAGE = 'C',
	LANG = 'C'
}

function module:initialize(shellScript)
	AbstractPosixShellScriptAction.initialize(self, shellScript)
end

assert.globalTypeIsFunction('ipairs')
function module:execute(sourcePath)
	assert.parameterTypeIsInstanceOf(sourcePath, AbstractPath)
	
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
	
	local unsetEnvironmentVariableShellScriptAction = UnsetEnvironmentVariablePosixShellScriptAction:new(self.shellScript)
	for _, environmentVariableName in ipairs(environmentVariablesToUnset) do
		unsetEnvironmentVariableShellScriptAction:execute(environmentVariableName)
	end
	
	local exportEnvironmentVariableShellScriptAction = ExportEnvironmentVariablePosixShellScriptAction:new(self.shellScript)
	for environmentVariableName, environmentVariableValue in pairs(environmentVariablesToExport) do
		exportEnvironmentVariableShellScriptAction:execute(environmentVariableName, environmentVariableValue)
	end
	
	local changeDirectoryShellScriptAction = ChangeDirectoryPosixShellScriptAction:new(self.shellScript)
	changeDirectoryShellScriptAction:execute(sourcePath)
end
