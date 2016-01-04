--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local AbstractStartShellScriptAction = halimede.build.shellScriptActions.AbstractStartShellScriptAction
local CommentPosixShellScriptAction = require.sibling.CommentPosixShellScriptAction
local UnsetEnvironmentVariablePosixShellScriptAction = require.sibling.UnsetEnvironmentVariablePosixShellScriptAction
local ExportEnvironmentVariablePosixShellScriptAction = require.sibling.ExportEnvironmentVariablePosixShellScriptAction
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

local initialScriptLines = [=[#!/usr/bin/env sh
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


# Common functionality to unset a variable safely on all shells (ie mksh and pdksh, which don't like to unset something not set (when using set -u))
_program_unset()
{
	(unset "$1") 1>/dev/null 2>/dev/null && unset "$1"
}

# Compatibility functionality from shellfire
core_compatibility_which()
{
	command -v "$1"
}

_core_compatibility_builtInDoesNotExist()
{
	local builtInName="$1"
	local value="$(PATH='' core_compatibility_which "$builtInName")"
	if [ "$builtInName" = "$value" ]; then
		return 1
	fi
	return 0
}

core_exitError()
{
	exit $1 "$2"
}

core_commandLine_exitCode_SOFTWARE=70
core_commandLine_exitCode_OSFILE=72

core_compatibility_installPushdAndPopd()
{
	# bash, zsh are known to support this
	if _core_compatibility_builtInDoesNotExist pushd; then
		
		if ! _core_compatibility_builtInDoesNotExist popd; then
			core_exitError $core_commandLine_exitCode_SOFTWARE "Weird shell does not have pushd but does have popd (?feature detection bug?)!"
		fi
		
		_core_init_compatibility_pushdCount=0

		pushd()
		{
			local path="$1"
			eval "core_init_pushdStack${_core_init_compatibility_pushdCount}='$(pwd)'"
			_core_init_compatibility_pushdCount=$((_core_init_compatibility_pushdCount+1))
			cd "$path" 1>/dev/null
		}

		popd()
		{
			_core_init_compatibility_pushdCount=$((_core_init_compatibility_pushdCount-1))
			eval "local path=\"\$core_init_pushdStack${_core_init_compatibility_pushdCount}\""
			eval "unset core_init_pushdStack${_core_init_compatibility_pushdCount}"
			cd "$path" 1>/dev/null
		}
	
	else
		
		pushd()
		{
			builtin pushd "$@" 1>/dev/null
		}
	
		popd()
		{
			builtin popd "$@" 1>/dev/null
		}
		
	fi
}
core_compatibility_installPushdAndPopd
unset core_compatibility_installPushdAndPopd
unset _core_compatibility_builtInDoesNotExist
unset core_compatibility_which

# Make sure CDPATH doesn't interfere
_program_unset CDPATH


# Make sure HOME is properly set
if [ -z "${HOME+set}" ]; then
	export HOME=~
fi


# Make sure TMPDIR is properly set
_program_pathIsUsableForTemp()
{
	if [ -d "$1" ]; then
		if [ -r "$1" ]; then
			if [ -w "$1" ]; then
				if [ -x "$1" ]; then
					return 0
				fi
			fi
		fi
	fi
	return 1
}

if [ -z "${TMPDIR+set}" ]; then
	for _program_potentialTmpPath in /tmp /var/tmp "$HOME"
	do
		if _program_pathIsUsableForTemp "$_program_potentialTmpPath" ]; then
			export TMPDIR="$_program_potentialTmpPath"
			_program_unset _program_potentialTmpPath 
			break
		fi
	done
fi

if [ -z "${TMPDIR+set}" ]; then
	core_exitError $core_commandLine_exitCode_OSFILE "There is nothing writable we can use for TMPDIR; please explicitly set TMPDIR before running this script"
fi

unset _program_pathIsUsableForTemp
_program_unset _program_potentialTmpPath


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

HALIMEDE_SHELLSCRIPT_ABSOLUTE_FOLDER_PATH="$(_program_path_find)"
unset _program_path_find 1>/dev/null 2>/dev/null


# Record our original working directory
HALIMEDE_SHELLSCRIPT_ORIGINAL_WORKING_DIRECTORY="$(pwd)"


# Change to absolute folder path, so everything has a good known location
cd "$HALIMEDE_SHELLSCRIPT_ABSOLUTE_FOLDER_PATH" 1>/dev/null]=]

function module:initialize()
	AbstractStartShellScriptAction.initialize(self, CommentPosixShellScriptAction, UnsetEnvironmentVariablePosixShellScriptAction, ExportEnvironmentVariablePosixShellScriptAction, environmentVariablesToUnset, environmentVariablesToExport, initialScriptLines)
end
