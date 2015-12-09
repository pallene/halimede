--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractStartShellScriptAction = halimede.build.shellScriptActions.AbstractStartShellScriptAction
local UnsetEnvironmentVariablePosixShellScriptAction = require.sibling('UnsetEnvironmentVariablePosixShellScriptAction')
local ExportEnvironmentVariablePosixShellScriptAction = require.sibling('ExportEnvironmentVariablePosixShellScriptAction')
local ChangeDirectoryPosixShellScriptAction = require.sibling('ChangeDirectoryPosixShellScriptAction')
local RemoveRecursivelyWithForcePosixShellScriptAction = require.sibling('RemoveRecursivelyWithForcePosixShellScriptAction')
local MakeDirectoryRecursivelyPosixShellScriptAction = require.sibling('MakeDirectoryRecursivelyPosixShellScriptAction')
local Path = halimede.io.paths.Path


moduleclass('StartScriptPosixShellScriptAction', AbstractStartShellScriptAction)

local environmentVariablesToUnset = {
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

local initialLines = [=[#!/usr/bin/env sh
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

]=]

function module:initialize()
	AbstractStartShellScriptAction.initialize(self, UnsetEnvironmentVariablePosixShellScriptAction, ExportEnvironmentVariablePosixShellScriptAction, environmentVariablesToUnset, environmentVariablesToExport, initialLines)
end
