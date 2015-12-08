--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Path = halimede.io.paths.Path
local UnsetEnvironmentVariablePosixShellScriptAction = require.sibling('UnsetEnvironmentVariablePosixShellScriptAction')
local ExportEnvironmentVariablePosixShellScriptAction = require.sibling('ExportEnvironmentVariablePosixShellScriptAction')
local ChangeDirectoryPosixShellScriptAction = require.sibling('ChangeDirectoryPosixShellScriptAction')
local AbstractPosixShellScriptAction = require.sibling('AbstractPosixShellScriptAction')
local RemoveRecursivelyWithForcePosixShellScriptAction = require.sibling('RemoveRecursivelyWithForcePosixShellScriptAction')
local MakeDirectoryRecursivelyPosixShellScriptAction = require.sibling('MakeDirectoryRecursivelyPosixShellScriptAction')


moduleclass('StartScriptPosixShellScriptAction', AbstractPosixShellScriptAction)

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
	
	-- This script logic assumes a modern, POSIX-compatible shell, with a baseline of the last release of pdksh in 1999
	-- It also tries to work around deficiencies in bash versions (eg IFS) and support zsh and MKS Shell (but these aren't common or suitable for anything but bootstrap builds)
	self:_appendLinesToScript([=[#!/usr/bin/env sh
set -e
set -u
set -f

# For bash
(set -o posix) 1>/dev/null 2>/dev/null && set -o posix

# For MKS Shell
export DUALCASE=1

# For zsh
if [ -n "${ZSH_VERSION+set}" ]; then
	emulate sh
	NULLCMD=:
	# Pre-4.2 versions of Zsh (superseded as of 2004-03-19) do word splitting on ${1+"$[@]"}, which is not wanted
	[[alias -g ${1+"$[@]"}="$[@]"]]
	setopt NO_GLOB_SUBST
fi

# Make sure IFS is set to something sensible
IFS="$(printf ' \t\n')"

# Make sure CDPATH doesn't interfere
(unset CDPATH) 1>/dev/null 2>/dev/null && unset CDPATH

# Find the absolute path containing this script
_program_path_find()
{
	if [ "${0%/*}" = "$0" ]; then

		# We've been invoked by the interpreter as, say, bash program
		if [ -r "$0" ]; then
			pwd -P
		# Clutching at straws; probably run via a download, anonymous script, etc, weird execve, etc
		else
			printf '\n'
		fi
		
	else
	
		# We've been invoked with a relative or absolute path (also when invoked via PATH in a shell)
		
		_program_path_find_parentPath()
		{
			parentPath="${scriptPath%/*}"
			if [ -z "$parentPath" ]; then
				parentPath='/'
			fi
			cd "$parentPath" 1>/dev/null
		}
		
		if command -v realpath 1>/dev/null 2>/dev/null; then
			(
				scriptPath="$(realpath "$0")"
				
				_program_path_find_parentPath
				pwd -P
			)
		elif command -v readlink 1>/dev/null 2>/dev/null; then
			(
				scriptPath="$0"
				
				while [ -L "$scriptPath" ]
				do
					_program_path_find_parentPath
					scriptPath="$(readlink "$scriptPath")"
				done

				_program_path_find_parentPath
				pwd -P
			)
		else
			# This approach will fail in corner cases where the script itself is a symlink in a path not parallel with the concrete script
			(
				scriptPath="$0"
				
				_program_path_find_parentPath
				pwd -P
			)
		fi
		
	fi
}
cd "$(_program_path_find)" 1>/dev/null
unset _program_path_find 1>/dev/null 2>/dev/null

]=])
	
	local unsetEnvironmentVariableShellScriptAction = UnsetEnvironmentVariablePosixShellScriptAction:new(self.shellScript)
	for _, environmentVariableName in ipairs(environmentVariablesToUnset) do
		unsetEnvironmentVariableShellScriptAction:execute(environmentVariableName)
	end
	
	local exportEnvironmentVariableShellScriptAction = ExportEnvironmentVariablePosixShellScriptAction:new(self.shellScript)
	for environmentVariableName, environmentVariableValue in pairs(environmentVariablesToExport) do
		exportEnvironmentVariableShellScriptAction:execute(environmentVariableName, environmentVariableValue)
	end
	
	-- Actually, change to the folder above sourceFolder (ie recipe folder)
	-- Consider allowing expandable-arguments so we can have settings at shell script start we can change (eg if not supplied on the command line)
	-- Consider switching to actual shell script path
	local changeDirectoryShellScriptAction = ChangeDirectoryPosixShellScriptAction:new(self.shellScript)
	changeDirectoryShellScriptAction:execute(recipeFolderPath)
		
	local removeRecursivelyWithForceShellScriptAction = RemoveRecursivelyWithForcePosixShellScriptAction:new(self.shellScript)
	removeRecursivelyWithForceShellScriptAction:execute(buildFolderRelativePath)
	
	local makeDirectoryRecursivelyShellScriptAction = MakeDirectoryRecursivelyPosixShellScriptAction:new(self.shellScript)
	makeDirectoryRecursivelyShellScriptAction:execute(buildFolderRelativePath, '0755')
	
	changeDirectoryShellScriptAction:execute(buildFolderRelativePath)
end
