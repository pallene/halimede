--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local type = halimede.type
local assert = halimede.assert
local tabelize = require('halimede.table.tabelize').tabelize
local operatingSystemDetails = require('halimede').operatingSystemDetails
local exception = require('halimede.exception')
local class = require('halimede.middleclass')

local ShellLanguage = class('ShellLanguage')

ShellLanguage.static.standardIn = 0
ShellLanguage.static.standardOut = 1
ShellLanguage.static.standardError = 2

function ShellLanguage:initialize(pathSeparator, newline, shellScriptFileExtensionIncludingLeadingPeriod, silenced, searchesCurrentPath)
	assert.parameterTypeIsString(pathSeparator)
	assert.parameterTypeIsString(newline)
	assert.parameterTypeIsString(shellScriptFileExtensionIncludingLeadingPeriod)
	assert.parameterTypeIsString(silenced)
	assert.parameterTypeIsString(searchesCurrentPath)
	assert.parameterTypeIsString(quoteArgument)
	assert.parameterTypeIsString(toShellCommand)
	
	self.pathSeparator = pathSeparator
	self.newline = newline
	self.shellScriptFileExtensionIncludingLeadingPeriod = shellScriptFileExtensionIncludingLeadingPeriod
	self.silenced = silenced
	self.searchesCurrentPath = searchesCurrentPath

	self.silenceStandardIn = self:redirectInput(ShellLanguage.standardIn, silenced),
	self.silenceStandardOut = self:redirectOutput(ShellLanguage.standardOut, silenced),
	self.silenceStandardError = self:redirectOutput(ShellLanguage.standardError, silenced),
end

function ShellLanguage:quoteArgument(argument)
	exception.throw('AbstractMethod')
end

function ShellLanguage:_redirect(fileDescriptor, filePathOrFileDescriptor, symbol)
	local redirection
	if type.isNumber(filePathOrFileDescriptor) then
		redirection = '&' .. filePathOrFileDescriptor
	else
		redirection = self:quoteArgument(filePathOrFileDescriptor)
	end
	
	return fileDescriptor .. symbol .. redirection
end

function ShellLanguage:redirectInput(fileDescriptor, filePathOrFileDescriptor)
	assert.parameterTypeIsNumber(fileDescriptor)
	
	return self:_redirect(fileDescriptor, filePathOrFileDescriptor, '<')
end

function ShellLanguage:redirectOutput(fileDescriptor, filePathOrFileDescriptor)
	assert.parameterTypeIsNumber(fileDescriptor)
	
	return self:_redirect(fileDescriptor, filePathOrFileDescriptor, '>')
end

assert.globalTypeIsFunction('ipairs')
function ShellLanguage:toShellCommand(...)
	local arguments = {...}

	local commandBuffer = tabelize()
	
	for _, argument in ipairs(arguments) do
		if argument ~= nil then
			assert.parameterTypeIsString(argument)
			commandBuffer:insert(self:quoteArgument(argument))
		end
	end

	return commandBuffer:concat(' ')
end

function ShellLanguage:toShellCommandLine(...)
	return self:toShellCommand(...) .. self.newline
end

assert.globalTypeIsFunction('ipairs')
function ShellLanguage:appendLinesToScript(tabelizedScriptBuffer, ...)
	local lines = {...}
	for _, line in ipairs(lines) do
		tabelizedScriptBuffer:insert(line)
		tabelizedScriptBuffer:insert(self.newline)
	end
end

function ShellScript:appendCommandLineToScript(tabelizedScriptBuffer, ...)
	tabelizedScriptBuffer:insert(self.toShellCommandLine(...))
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'split')
function ShellLanguage:iteratePath(path)
	if path == nil then
		return nil
	end
	
	local paths = path:split(self.pathSeparator)
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

function ShellLanguage:binarySearchPath()
	local PATH
	local searchPaths
	
	if type.hasPackageChildFieldOfTypeFunctionOrCall('os', 'getenv') then
		-- Can be nil
		PATH = os.getenv('PATH')
	else
		PATH = nil
	end

	-- In Windows, the current working directory is considered a part of the path
	if self.searchesCurrentPath then
		if PATH == nil then
			return '.'
		else
			return '.' .. self.pathSeparator .. PATH
		end
	else
		return PATH
	end
end


local PosixShellLanguage = class('POSIX', ShellLanguage)

function PosixShellLanguage:initialize()
	ShellLanguage.initialize(self, ':', '\n', '', '/dev/null', false)
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'gsub')
function PosixShellLanguage:quoteArgument(argument)
	assert.parameterTypeIsString(argument)
	
	return "'" .. argument:gsub("'", "''") .. "'"
end

ShellLanguage.static.POSIX = PosixShellLanguage:new()


local WindowsShellLanguage = class('Windows', ShellLanguage)

function WindowsShellLanguage:initialize()
	ShellLanguage.initialize(self, ';', '\r\n', '.bat', 'NUL', true)
end

local slash = '\\'

local windowsCharactersToEscape = {
  ['%'] = '%%',
  ['"'] = '\\"',
}

assert.globalTableHasChieldFieldOfTypeFunction('string', 'rep')
local function windowsEscaperA(capture1, capture2)
  return slash:rep(2 * #capture1 - 1) .. (capture2 or slash)
end

local function windowsEscaperB(value)
   return value .. value .. '"%"'
end

-- Quoting is a mess in Windows; these rules only work for cmd.exe /C (it's a per-program thing)
assert.globalTableHasChieldFieldOfTypeFunction('string', 'match', 'gsub')
function WindowsShellLanguage:quoteArgument(argument)
	assert.parameterTypeIsString(argument)
	
	-- Quote a DIR including any drive or UNC letters, replacing any POSIX-isms
    if argument:match('^[%.a-zA-Z]?:?[\\/]')  then
       argument = argument:gsub('/', slash)
    end
	
	-- Special handling for CHDIR with \
	if argument == slash then
		return argument
	end
	
	-- Quoting for URLs
   argument = argument:gsub('(\\+)(")', windowsEscaperA)
   argument = argument:gsub('(\\+)$', windowsEscaperA)
   argument = argument:gsub('[%%"]', windowsCharactersToEscape)
   argument = argument:gsub('(\\*)%%', windowsEscaperB)
   
   return '"' .. argument .. '"'
end

-- http://lua-users.org/lists/lua-l/2013-11/msg00367.html
function WindowsShellLanguage:toShellCommand(...)
	return ShellLanguage.toShellCommand(self, 'type NUL &&', ...)
end

ShellLanguage.static.Windows = WindowsShellLanguage:new()


local operatingSystemDetails = halimede.operatingSystemDetails
local default
if operatingSystemDetails.isPosix then
	default = ShellLanguage.POSIX
elseif halimede.operatingSystemDetails.isWindows then
	default = ShellLanguage.Windows
else
	exception.throw('Could not determine ShellLanguage')
end
ShellLanguage.static.Default = default


return ShellLanguage
