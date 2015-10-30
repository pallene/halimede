--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('middleclass')
local CompileUnitActions = requireSibling('CompileUnitActions')
local AbstractPath = require('halimede.io.paths.AbstractPath')
local Paths = require('halimede.io.paths.Paths')
local ShellLanguage = require('halimede.io.ShellLanguage')


local PosixCompileUnitActions = class('PosixCompileUnitActions', CompileUnitActions)

local PosixCompileUnitActions.static.environmentVariablesToUnsetAtBuildScriptStart = {
	'CDPATH',
	'BASH_ENV',
	'ENV',
	'MAIL',
	'MAILPATH',
	
	'GCC_EXEC_PREFIX',
	'COMPILER_PATH',
	'LIBRARY_PATH',
	'LANG', -- actually wants a value to match C source
	'CPATH',
	'C_INCLUDE_PATH',
	'CPLUS_INCLUDE_PATH',
	'OBJC_INCLUDE_PATH',
	'DEPENDENCIES_OUTPUT',
	'SUNPRO_DEPENDENCIES'
}

function PosixCompileUnitActions:initialize(sourcePath, sysrootPath, toolchain)
	AbstractCompileUnitActions.initialise(self, ShellLanguage.POSIX, sourcePath, sysrootPath, toolchain)
end

assert.globalTypeIsFunction('ipairs')
function PosixCompileUnitActions:_initialBuildScript()
	
	-- TODO: TMPDIR, COMPILER_PATH, LIBRARY_PATH, more ... http://linux.die.net/man/1/gcc
	
	-- Can't use a multiline string because the new line terminator is wrong if this file is edited by some Windows programs
	-- NOTE: We don't try to support ancient non-POSIX shells that don't like export VAR=VALUE syntax
	self:appendLinesToBuildScript(
		'#!/usr/bin/env sh',
		'set -e',
		'set -u',
		'set -f',
		'IFS=" $(printf \'\\t\')$(printf \'\\n\')"',  -- Space, Tab, Newline
		'export LC_ALL=C',
		'export LC_CTYPE=C',
		'export LC_MESSAGES=C',
		'export LANGUAGE=C',
		"PS1='$ '",
		"PS2='> '",
		"PS4='+ '",
		'export DUALCASE=1',  -- For MKS Shell
		'if [ -n "${ZSH_VERSION+set}" ]; then',  -- For zsh
		'    emulate sh',
		'    NULLCMD=:',
		'    # Pre-4.2 versions of Zsh (superceded as of 2004-03-19) do word splitting on ${1+"$[@]"}, which is not wanted',
		[[    alias -g '${1+"$[@]"}'='"$[@]"']],
		'    setopt NO_GLOB_SUBST',
		'fi',
		'(set -o posix) 1>/dev/null 2>/dev/null && set -o posix'  -- For bash
		'PATH_SEPARATOR="' .. Paths.pathSeparator .. '"'
	)
	for _, environmentVariableToUnsetAtBuildScriptStart in ipairs(environmentVariablesToUnsetAtBuildScriptStart) do
		self:actionUnsetEnvironmentVariable(environmentVariableToUnsetAtBuildScriptStart)
	end
end

function PosixCompileUnitActions:_finalBuildScript()
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'format')
function PosixCompileUnitActions:actionUnsetEnvironmentVariable(variableName)
	assert.parameterTypeIsString(variableName)
	
	-- Complexity is to cope with the mksh and pdksh shells, which don't like to unset something not set (when using set -u)
	self:appendCommandLineToBuildScript(('(unset %s) 1>/dev/null 2>/dev/null && unset %s'):format(variableName))
end

function PosixCompileUnitActions:actionSetPath(paths)
	assert.parameterTypeIsInstanceOf(paths, Paths)
	
	self:actionUnsetEnvironmentVariable('PATH')
	self:appendCommandLineToBuildScript('export', 'PATH=' .. paths.paths)
end

function PosixCompileUnitActions:actionChangeDirectory(abstractPath)
	assert.parameterTypeIsInstanceOf(sourcePath, AbstractPath)
	
	self:appendCommandLineToBuildScript('cd', abstractPath.path)
end

function PosixCompileUnitActions:actionMakeDirectoryParent(abstractPath, mode)
	assert.parameterTypeIsInstanceOf(abstractPath, AbstractPath)
	assert.parameterTypeIsString(mode)
	
	self:appendCommandLineToBuildScript('mkdir', '-m', mode, '-p', abstractPath, mode.path)
end

function PosixCompileUnitActions:actionRemoveRecursivelyWithForce(abstractPath)
	assert.parameterTypeIsInstanceOf(abstractPath, AbstractPath)
	
	self:appendCommandLineToBuildScript('rm', '-rf', abstractPath.path)
end

return PosixCompileUnitActions
