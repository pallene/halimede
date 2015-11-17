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
local Path = require('halimede.io.paths.Path')
local Paths = require('halimede.io.paths.Paths')
local PathStyle = require('halimede.io.paths.PathStyle')



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
function module:initialize(lowerCasedName, titleCasedName, pathStyle, newline, shellScriptFileExtensionIncludingLeadingPeriod, silenced, searchesCurrentPath, commandInterpreterName)
	assert.parameterTypeIsString(lowerCasedName)
	assert.parameterTypeIsString(titleCasedName)
	assert.parameterTypeIsInstanceOf(pathStyle, PathStyle)
	assert.parameterTypeIsString(newline)
	assert.parameterTypeIsString(shellScriptFileExtensionIncludingLeadingPeriod)
	assert.parameterTypeIsString(silenced)
	assert.parameterTypeIsString(searchesCurrentPath)
	assert.parameterTypeIsString(commandInterpreterName)
	
	self.lowerCasedName = lowerCasedName
	self.titleCasedName = titleCasedName
	self.pathStyle = pathStyle
	self.newline = newline
	self.shellScriptFileExtensionIncludingLeadingPeriod = shellScriptFileExtensionIncludingLeadingPeriod
	self.silenced = silenced
	self.searchesCurrentPath = searchesCurrentPath
	self.commandInterpreterName = commandInterpreterName

	self.silenceStandardIn = self:redirectStandardInput(silenced),
	self.silenceStandardOut = self:redirectStandardOutput(silenced),
	self.silenceStandardError = self:redirectStandardError(silenced),
end

function module:quoteArgument(argument)
	exception.throw('AbstractMethod')
end

function module:_redirect(fileDescriptor, filePathOrFileDescriptor, symbol)
	local redirection
	if type.isNumber(filePathOrFileDescriptor) then
		redirection = '&' .. filePathOrFileDescriptor
	else
		redirection = self:quoteArgument(filePathOrFileDescriptor)
	end
	
	return fileDescriptor .. symbol .. redirection
end

function module:redirectInput(fileDescriptor, filePathOrFileDescriptor)
	assert.parameterTypeIsNumber(fileDescriptor)
	
	return self:_redirect(fileDescriptor, filePathOrFileDescriptor, '<')
end

function module:redirectOutput(fileDescriptor, filePathOrFileDescriptor)
	assert.parameterTypeIsNumber(fileDescriptor)
	
	return self:_redirect(fileDescriptor, filePathOrFileDescriptor, '>')
end

function module:redirectStandardInput(filePathOrFileDescriptor)
	return self:redirectInput(ShellLanguage.standardIn, filePathOrFileDescriptor)
end

function module:redirectStandardOutput(filePathOrFileDescriptor)
	return self:redirectOutput(ShellLanguage.standardOut, filePathOrFileDescriptor)
end

function module:redirectStandardError(filePathOrFileDescriptor)
	return self:redirectOutput(ShellLanguage.standardError, filePathOrFileDescriptor)
end

assert.globalTypeIsFunction('ipairs')
function module:toShellCommand(...)
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

function module:toShellCommandLine(...)
	return self:toShellCommand(...) .. self.newline
end

assert.globalTypeIsFunction('ipairs')
function module:appendLinesToScript(tabelizedScriptBuffer, ...)
	local lines = {...}
	for _, line in ipairs(lines) do
		tabelizedScriptBuffer:insert(line)
	end
end

function ShellScript:appendCommandLineToScript(tabelizedScriptBuffer, ...)
	tabelizedScriptBuffer:insert(self.toShellCommandLine(...))
end

assert.globalTypeIsFunction('ipairs')
function module:paths(stringPathsTable)
	assert.parameterTypeIsTable(stringPathsTable)
	
	local paths = tabelize()
	
	for _, stringPath in ipairs(stringPathsTable) do
		assert.parameterTypeIsString(stringPath)
		
		local path = self.pathStyle:parse(stringPath, false)
		path:insert(path)
	end
	
	return Paths:new(self.pathStyle, paths)
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'split')
function module:binarySearchPath()
	local PATH
	local searchPaths
	
	if type.hasPackageChildFieldOfTypeFunctionOrCall('os', 'getenv') then
		-- Can be nil
		PATH = os.getenv('PATH')
	else
		PATH = nil
	end
	
	local combined
	-- In Windows, the current working directory is considered a part of the path
	if self.searchesCurrentPath then
		if PATH == nil then
			return self:paths({'.'})
		else
			combined = '.' .. self.pathStyle.pathSeparator .. PATH
		end
	elseif PATH == nil then
		return self:paths({})
	else
		combined = PATH
	end
	
	return self:paths(combined:split(self.pathStyle.pathSeparator))
end


local PosixShellLanguage = class('PosixShellLanguage', ShellLanguage)

function PosixShellLanguage:initialize()
	ShellLanguage.initialize(self, 'posix', 'Posix', PathStyle.Posix, '\n', '', '/dev/null', false, 'sh')
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'gsub')
function PosixShellLanguage:quoteArgument(argument)
	assert.parameterTypeIsString(argument)
	
	return "'" .. argument:gsub("'", "''") .. "'"
end

ShellLanguage.static.Posix = PosixShellLanguage:new()


local CmdShellLanguage = class('CmdShellLanguage', ShellLanguage)

function CmdShellLanguage:initialize()
	ShellLanguage.initialize(self, 'cmd', 'Cmd', PathStyle.Cmd, '\r\n', '.cmd', 'NUL', true, 'cmd')
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
