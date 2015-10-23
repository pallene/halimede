--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local type = halimede.type
local assert = halimede.assert
local tabelize = require('halimede.tabelize').tabelize
local operatingSystemDetails = require('halimede').operatingSystemDetails
local exception = require('halimede.exception')


assert.globalTableHasChieldFieldOfTypeFunction('string', 'gsub')
local function quotePosixArgument(argument)
	return "'" .. argument:gsub("'", "''") .. "'"
end

local slash = '\\'
assert.globalTableHasChieldFieldOfTypeFunction('string', 'rep')
local function windowsEscaperA(capture1, capture2)
  return slash:rep(2 * #capture1 - 1) .. (capture2 or slash)
end

local windowsCharactersToEscape = {
  ['%'] = '%%',
  ['"'] = '\\"',
}

local function windowsEscaperB(value)
   return value .. value .. '"%"'
end

-- Quoting is a mess in Windows; these rules only work for cmd.exe /C (it's a per-program thing)
assert.globalTableHasChieldFieldOfTypeFunction('string', 'match', 'gsub')
local function quoteWindowsArgument(argument)
	assert.parameterTypeIsString(argument)
	
	-- Quote a DIR including any drive or UNC letters, replacing any POSIX-isms
    if argument:match('^[%.a-zA-Z]?:?[\\/]')  then
       argument = argument:gsub('/', '\\')
    end
	
	-- Special handling for CHDIR with \
	if argument == '\\' then
		return argument
	end
	
	-- Quoting for URLs
   argument = argument:gsub('(\\+)(")', windowsEscaperA)
   argument = argument:gsub('(\\+)$', windowsEscaperA)
   argument = argument:gsub('[%%"]', windowsCharactersToEscape)
   argument = argument:gsub('(\\*)%%', windowsEscaperB)
   return '"' .. argument .. '"'
end

local function toShellCommand(quoteArgument, ...)
	local arguments = {...}

	local commandBuffer = tabelize()
	
	for _, argument in ipairs(arguments) do
		commandBuffer:insert(quoteArgument(argument))
	end

	return commandBuffer:concat(' ')
end

local function redirect(quoteArgument, fileDescriptor, filePathOrFileDescriptor)
	local redirection
	if type.isNumber(filePathOrFileDescriptor) then
		redirection = '&' .. filePathOrFileDescriptor
	else
		redirection = quoteArgument(filePathOrFileDescriptor)
	end
	
	return fileDescriptor .. '>' .. redirection
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'split')
local function newShellLanguage(pathSeparator, silenced, searchesCurrentPath, quoteArgument, toShellCommand)
	
	local function redirectQuoted(fileDescriptor, filePathOrFileDescriptor)
		return redirect(quoteArgument, fileDescriptor, filePathOrFileDescriptor)
	end
	
	local function iteratePath(path)
		if path == nil then
			return nil
		end
		
		local paths = path:split(pathSeparator)
		local index = 0
		local count = #paths
		return function()
			index = index + 1
			if index > count then
				return nil
			end
			return paths[index]
		end
	end
	
	local function findBinarySearchPath()
		local PATH
		local searchPaths
		
		if type.hasPackageChildFieldOfTypeFunctionOrCall('os', 'getenv') then
			-- Can be nil
			PATH = os.getenv('PATH')
		else
			PATH = nil
		end
	
		-- In Windows, the current working directory is considered a part of the path
		if searchesCurrentPath then
			if PATH == nil then
				return '.'
			else
				return '.' .. pathSeparator .. PATH
			end
		else
			return PATH
		end
	end
	local binarySearchPath = findBinarySearchPath()
	
	local standardOut = 1
	local standardError = 2
	
	local functions = {
		standardOut = standardOut,
		standardError = standardError,
		pathSeparator = pathSeparator,
		silenced = silenced,
		redirect = redirectQuoted,
		silenceStandardOut = redirectQuoted(standardOut, silenced),
		silenceStandardError = redirectQuoted(standardError, silenced),
		toShellCommand =  toShellCommand,
		binarySearchPath = binarySearchPath
	}
	
	return functions
end

local POSIX = newShellLanguage(':', '/dev/null', false, quotePosixArgument, function(...)
	return toShellCommand(quotePosixArgument, ...)
end)
module.POSIX = POSIX

local Windows = newShellLanguage(';', 'NUL', true, quoteWindowsArgument, function(...)
	-- http://lua-users.org/lists/lua-l/2013-11/msg00367.html
	return toShellCommand(quoteWindowsArgument, 'type NUL &&', ...)
end)

if halimede.operatingSystemDetails.isPosix then
	module.Default = module.POSIX
elseif halimede.operatingSystemDetails.isWindows then
	module.Default = module.Windows
else
	exception.throw('Could not determine ShellLanguage')
end
