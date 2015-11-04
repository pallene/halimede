--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local ShellLanguage = moduleclass('ShellLanguage')

local halimede = require('halimede')
local type = halimede.type
local assert = halimede.assert
local tabelize = require('halimede.table.tabelize').tabelize
local operatingSystemDetails = require('halimede').operatingSystemDetails
local exception = require('halimede.exception')
local class = require('halimede.middleclass')


ShellLanguage.static.standardIn = 0
ShellLanguage.static.standardOut = 1
ShellLanguage.static.standardError = 2

--[[
local type = halimede.type
local exception = require('halimede.exception')
assert.globalTableHasChieldFieldOfTypeFunction('string', 'format')
local function validateLocale()
	local function currentLocaleShouldBe(category, shouldBe)
		local is = os.setlocale('nil', category)
		if is ~= nil and is ~= shouldBe then
			exception.throw("The OS locale category '%s' must be set to '%s' so that string.tolower can be used reliably", category, shouldBe)
		end
	end
	
	if type.hasPackageChildFieldOfTypeFunctionOrCall('os', 'setlocale') then
		currentLocaleShouldBe('all', 'C')
		currentLocaleShouldBe('ctype', 'C')
		currentLocaleShouldBe('collate', 'C')
	end
end
validateLocale()
]]--
-- The reason we have a lower case and title case variant is that we avoid the need to use string:lower(), which depends on os.setlocale('all', 'C') to be deterministic, which isn't safe to use (we could be Lua code in a thread or embedded in an application that has already set setlocale())
function ShellLanguage:initialize(lowerCasedName, titleCasedName, folderSeparator, pathSeparator, newline, shellScriptFileExtensionIncludingLeadingPeriod, silenced, searchesCurrentPath, commandInterpreterName)
	assert.parameterTypeIsString(lowerCasedName)
	assert.parameterTypeIsString(titleCasedName)
	assert.parameterTypeIsString(pathSeparator)
	assert.parameterTypeIsString(newline)
	assert.parameterTypeIsString(shellScriptFileExtensionIncludingLeadingPeriod)
	assert.parameterTypeIsString(silenced)
	assert.parameterTypeIsString(searchesCurrentPath)
	assert.parameterTypeIsString(commandInterpreterName)
	
	self.lowerCasedName = lowerCasedName
	self.titleCasedName = titleCasedName
	self.folderSeparator = folderSeparator
	self.pathSeparator = pathSeparator
	self.newline = newline
	self.shellScriptFileExtensionIncludingLeadingPeriod = shellScriptFileExtensionIncludingLeadingPeriod
	self.silenced = silenced
	self.searchesCurrentPath = searchesCurrentPath
	self.commandInterpreterName = commandInterpreterName

	self.silenceStandardIn = self:redirectStandardInput(silenced),
	self.silenceStandardOut = self:redirectStandardOutput(silenced),
	self.silenceStandardError = self:redirectStandardError(silenced),
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

function ShellLanguage:redirectStandardInput(filePathOrFileDescriptor)
	return self:redirectInput(ShellLanguage.standardIn, filePathOrFileDescriptor)
end

function ShellLanguage:redirectStandardOutput(filePathOrFileDescriptor)
	return self:redirectOutput(ShellLanguage.standardOut, filePathOrFileDescriptor)
end

function ShellLanguage:redirectStandardError(filePathOrFileDescriptor)
	return self:redirectOutput(ShellLanguage.standardError, filePathOrFileDescriptor)
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


local PosixShellLanguage = class('PosixShellLanguage', ShellLanguage)

function PosixShellLanguage:initialize()
	ShellLanguage.initialize(self, 'posix', 'Posix', '/', ':', '\n', '', '/dev/null', false, 'sh')
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'gsub')
function PosixShellLanguage:quoteArgument(argument)
	assert.parameterTypeIsString(argument)
	
	return "'" .. argument:gsub("'", "''") .. "'"
end

ShellLanguage.static.Posix = PosixShellLanguage:new()


local CmdShellLanguage = class('CmdShellLanguage', ShellLanguage)

function CmdShellLanguage:initialize()
	ShellLanguage.initialize(self, 'cmd', 'Cmd', '\\', ';', '\r\n', '.cmd', 'NUL', true, 'cmd')
end

local slash = '\\'

local cmdCharactersToEscape = {
  ['%'] = '%%',
  ['"'] = '\\"',
}

assert.globalTableHasChieldFieldOfTypeFunction('string', 'rep')
local function cmdEscaperA(capture1, capture2)
  return slash:rep(2 * #capture1 - 1) .. (capture2 or slash)
end

local function cmdEscaperB(value)
   return value .. value .. '"%"'
end

-- Quoting is a mess in Cmd; these rules only work for cmd.exe /C (it's a per-program thing)
assert.globalTableHasChieldFieldOfTypeFunction('string', 'match', 'gsub')
function CmdShellLanguage:quoteArgument(argument)
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
   argument = argument:gsub('(\\+)(")', cmdEscaperA)
   argument = argument:gsub('(\\+)$', cmdEscaperA)
   argument = argument:gsub('[%%"]', cmdCharactersToEscape)
   argument = argument:gsub('(\\*)%%', cmdEscaperB)
   
   return '"' .. argument .. '"'
end

-- http://lua-users.org/lists/lua-l/2013-11/msg00367.html
function CmdShellLanguage:toShellCommand(...)
	return ShellLanguage.toShellCommand(self, 'type NUL &&', ...)
end

ShellLanguage.static.Cmd = CmdShellLanguage:new()


local operatingSystemDetails = halimede.operatingSystemDetails
local default
if operatingSystemDetails.isPosix then
	default = ShellLanguage.Posix
elseif halimede.operatingSystemDetails.isCmd then
	default = ShellLanguage.Cmd
else
	exception.throw('Could not determine ShellLanguage')
end
ShellLanguage.static.Default = default
