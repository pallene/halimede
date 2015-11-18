--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local ShellLanguage = moduleclass('ShellLanguage')

local halimede = require('halimede')
local tabelize = require('halimede.table.tabelize').tabelize
local packageConfiguration = require('halimede').packageConfiguration
local exception = require('halimede.exception')
local Path = require('halimede.io.paths.Path')
local Paths = require('halimede.io.paths.Paths')
local PathStyle = require('halimede.io.paths.PathStyle')


ShellLanguage.static.standardIn = 0
ShellLanguage.static.standardOut = 1
ShellLanguage.static.standardError = 2

-- The reason we have a lower case and title case variant is that we avoid the need to use string:lower(), which depends on os.setlocale('all', 'C') to be deterministic, which isn't safe to use (we could be Lua code in a thread or embedded in an application that has already set setlocale())
function module:initialize(lowerCasedName, titleCasedName, pathStyle, newline, shellScriptFileExtensionExcludingLeadingPeriod, silenced, searchesCurrentPath, commandInterpreterName)
	assert.parameterTypeIsString('lowerCasedName', lowerCasedName)
	assert.parameterTypeIsString('titleCasedName', titleCasedName)
	assert.parameterTypeIsInstanceOf('pathStyle', pathStyle, PathStyle)
	assert.parameterTypeIsString('newline', newline)
	assert.parameterTypeIsStringOrNil('shellScriptFileExtensionExcludingLeadingPeriod', shellScriptFileExtensionExcludingLeadingPeriod)
	assert.parameterTypeIsString('silenced', silenced)
	assert.parameterTypeIsString('searchesCurrentPath', searchesCurrentPath)
	assert.parameterTypeIsString('commandInterpreterName', commandInterpreterName)
	
	self.lowerCasedName = lowerCasedName
	self.titleCasedName = titleCasedName
	self.pathStyle = pathStyle
	self.newline = newline
	self.shellScriptFileExtensionExcludingLeadingPeriod = shellScriptFileExtensionExcludingLeadingPeriod
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
	assert.parameterTypeIsNumber('fileDescriptor', fileDescriptor)
	
	return self:_redirect(fileDescriptor, filePathOrFileDescriptor, '<')
end

function module:redirectOutput(fileDescriptor, filePathOrFileDescriptor)
	assert.parameterTypeIsNumber('fileDescriptor', fileDescriptor)
	
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
			assert.parameterTypeIsString('argument', argument)
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

function module:appendCommandLineToScript(tabelizedScriptBuffer, ...)
	tabelizedScriptBuffer:insert(self.toShellCommandLine(...))
end

function module:parsePath(pathString, isFile)
	assert.parameterTypeIsString('pathString', pathString)
	assert.parameterTypeIsBoolean('isFile', isFile)
	
	return self.pathStyle:parse(pathString, isFile)
end

function module:relativeFolderPath(...)
	return self.pathStyle:relativeFolderPath(...)
end

function module:relativeFilePath(...)
	return self.pathStyle:relativeFilePath(...)
end

function module:appendFileExtension(fileName, fileExtension)
	assert.parameterTypeIsString('fileName', fileName)
	assert.parameterTypeIsStringOrNil('fileExtension', fileExtension)
	
	return self.pathStyle:appendFileExtension(fileName, fileExtension)
end

assert.globalTypeIsFunction('ipairs')
function module:paths(stringPathsTable)
	assert.parameterTypeIsTable('stringPathsTable', stringPathsTable)
	
	local paths = tabelize()
	
	for _, stringPath in ipairs(stringPathsTable) do
		assert.parameterTypeIsString('stringPath', stringPath)
		
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
	ShellLanguage.initialize(self, 'posix', 'Posix', PathStyle.Posix, '\n', nil, '/dev/null', false, 'sh')
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'gsub')
function PosixShellLanguage:quoteArgument(argument)
	assert.parameterTypeIsString('argument', argument)
	
	return "'" .. argument:gsub("'", "''") .. "'"
end

ShellLanguage.static.Posix = PosixShellLanguage:new()


local CmdShellLanguage = class('CmdShellLanguage', ShellLanguage)

function CmdShellLanguage:initialize()
	ShellLanguage.initialize(self, 'cmd', 'Cmd', PathStyle.Cmd, '\r\n', 'cmd', 'NUL', true, 'cmd')
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
	assert.parameterTypeIsString('argument', argument)
	
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

-- Not the best test; doesn't work for Symbian, can't distinguish OpenVms from RISC OS
-- Running uname on the PATH works on POSIX systems, but that rules out Windows... and the shell isn't available on Unikernels like RumpKernel
local folderSeparator = packageConfiguration.folderSeparator
local default
if folderSeparator == '/' then
	default = ShellLanguage.Posix
elseif folderSeparator == '\\' then
	default = ShellLanguage.Cmd
else
	exception.throw("Could not determine ShellLanguage using packageConfiguration folderSeparator '%s'", folderSeparator)
end
ShellLanguage.static.Default = default
