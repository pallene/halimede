--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local tabelize = halimede.table.tabelize
local packageConfiguration = halimede.packageConfiguration
local exception = halimede.exception
local Path = halimede.io.paths.Path
local Paths = halimede.io.paths.Paths
local PathStyle = halimede.io.paths.PathStyle
local AlreadyEscapedShellArgument = require.sibling('AlreadyEscapedShellArgument')


local ShellLanguage = moduleclass('ShellLanguage')

local executeFunction
if type.hasPackageChildFieldOfTypeFunctionOrCall('os', 'execute') then
	executeFunction = os.execute
else
	executeFunction = function(command)
		assert.parameterTypeIsStringOrNil('command', command)
		
		if command == nil then
			return false
		end
		return nil, 'exit', 126
	end
end
module.static.shellIsAvailable = executeFunction() == true


module.static.noRedirection = false  -- Bizarre but works
module.static.standardIn = 0
module.static.standardOut = 1
module.static.standardError = 2

-- The reason we have a lower case and title case variant is that we avoid the need to use string:lower(), which depends on os.setlocale('all', 'C') to be deterministic, which isn't safe to use (we could be Lua code in a thread or embedded in an application that has already set setlocale())
function module:initialize(lowerCasedName, titleCasedName, pathStyle, newline, shellScriptFileExtensionExcludingLeadingPeriod, silenced, searchesCurrentPath, commandInterpreterName)
	assert.parameterTypeIsString('lowerCasedName', lowerCasedName)
	assert.parameterTypeIsString('titleCasedName', titleCasedName)
	assert.parameterTypeIsInstanceOf('pathStyle', pathStyle, PathStyle)
	assert.parameterTypeIsString('newline', newline)
	assert.parameterTypeIsStringOrNil('shellScriptFileExtensionExcludingLeadingPeriod', shellScriptFileExtensionExcludingLeadingPeriod)
	assert.parameterTypeIsString('silenced', silenced)
	assert.parameterTypeIsBoolean('searchesCurrentPath', searchesCurrentPath)
	assert.parameterTypeIsString('commandInterpreterName', commandInterpreterName)
	
	self.lowerCasedName = lowerCasedName
	self.titleCasedName = titleCasedName
	self.pathStyle = pathStyle
	self.newline = newline
	self.shellScriptFileExtensionExcludingLeadingPeriod = shellScriptFileExtensionExcludingLeadingPeriod
	self.silenced = silenced
	self.searchesCurrentPath = searchesCurrentPath
	self.commandInterpreterName = commandInterpreterName

	self.silenceStandardIn = self:redirectStandardInput(silenced)
	self.silenceStandardOut = self:redirectStandardOutput(silenced)
	self.silenceStandardError = self:redirectStandardError(silenced)
end

function module:execute(standardIn, standardOut, standardError, ...)

	local arguments = tabelize({...})
	if standardIn then
		arguments:insert(self:redirectStandardInput(standardIn))
	end
	if standardOut then
		arguments:insert(self:redirectStandardOutput(standardOut))
	end
	if standardError then
		arguments:insert(self:redirectStandardError(standardError))
	end

	local command = self:toShellCommand(...)

	-- Lua 5.1: returns an exit code
	-- Lua 5.2 / 5.3: returns true or nil, string ('exit' or 'signal'), exit/signal code
	local exitCodeOrBoolean, terminationKind, exitCode = executeFunction(command)
	if type.isNil(exitCodeOrBoolean) then
		return false, terminationKind, exitCode, command
	elseif type.isBoolean(exitCodeOrBoolean) then
		return exitCodeOrBoolean, terminationKind, exitCode, command
	else
		return exitCodeOrBoolean == 0, 'exit', exitCodeOrBoolean, command
	end
end

function module:executeExpectingSuccess(standardIn, standardOut, standardError, ...)
	local success, terminationKind, exitCode, command = self:execute(standardIn, standardOut, standardError, ...)
	if not success then
		exception.throw("Could not execute shell command, returned exitCode '%s' for command (%s)", exitCode, command)
	end
end

-- NOTE: This approach is slow, as it opens the executable for reading
-- NOTE: This approach can not determine if a binary is +x (executable) or not
local openTextModeForReading
assert.globalTypeIsFunction('pcall')
function module:commandIsOnPath(command)
	assert.parameterTypeIsString('command', command)
	
	-- To avoid pulling in a dependency on io functions unless this function is actually used
	if openTextModeForReading == nil then
		openTextModeForReading = halimede.io.read.openTextModeForReading
	end
	
	for path in self:binarySearchPath():iterate() do
		local pathToBinary = path:appendFile(command)
		
		local ok, fileHandleOrError = pcall(openTextModeForReading, pathToBinary, command)
		if ok then
			local fileHandle = fileHandleOrError
			fileHandle:close()
			return true, pathToBinary
		end
	end
	
	return false, nil
end

function module:commandIsOnPathAndShellIsAvaiableToUseIt(command)
	assert.parameterTypeIsString('command', command)
	
	if ShellLanguage.shellIsAvailable then
		return self:commandIsOnPath(command)
	else
		return false
	end
end

function module:quoteArgument(argument)
	if type.isString(argument) then
		return self:_quoteArgument(argument)
	end
	
	assert.parameterTypeIsInstanceOf('argument', argument, AlreadyEscapedShellArgument)
	return argument
end

function module:_quoteArgument(argument)
	exception.throw('AbstractMethod')
end

function module:_redirect(fileDescriptor, filePathOrFileDescriptor, symbol)
	local redirection
	if type.isNumber(filePathOrFileDescriptor) then
		redirection = '&' .. filePathOrFileDescriptor
	else
		redirection = self:quoteArgument(filePathOrFileDescriptor)
	end
	
	return AlreadyEscapedShellArgument:new(fileDescriptor .. symbol .. redirection)
end

function module:redirectInput(fileDescriptor, filePathOrFileDescriptor)
	assert.parameterTypeIsPositiveInteger('fileDescriptor', fileDescriptor)
	assert.parameterTypeIsNumberOrString('filePathOrFileDescriptor', filePathOrFileDescriptor)
	
	return self:_redirect(fileDescriptor, filePathOrFileDescriptor, '<')
end

function module:redirectOutput(fileDescriptor, filePathOrFileDescriptor)
	assert.parameterTypeIsPositiveInteger('fileDescriptor', fileDescriptor)
	assert.parameterTypeIsNumberOrString('filePathOrFileDescriptor', filePathOrFileDescriptor)
	
	return self:_redirect(fileDescriptor, filePathOrFileDescriptor, '>')
end

function module:redirectStandardInput(filePathOrFileDescriptor)
	assert.parameterTypeIsNumberOrString('filePathOrFileDescriptor', filePathOrFileDescriptor)
	
	return self:redirectInput(ShellLanguage.standardIn, filePathOrFileDescriptor)
end

function module:redirectStandardOutput(filePathOrFileDescriptor)
	assert.parameterTypeIsNumberOrString('filePathOrFileDescriptor', filePathOrFileDescriptor)
	
	return self:redirectOutput(ShellLanguage.standardOut, filePathOrFileDescriptor)
end

function module:redirectStandardError(filePathOrFileDescriptor)
	assert.parameterTypeIsNumberOrString('filePathOrFileDescriptor', filePathOrFileDescriptor)
	
	return self:redirectOutput(ShellLanguage.standardError, filePathOrFileDescriptor)
end

assert.globalTypeIsFunction('ipairs')
function module:toShellCommand(...)
	local arguments = {...}
	
	local commandBuffer = tabelize()
	
	for _, argument in ipairs(arguments) do
		if argument ~= nil then
			if type.isString(argument) then
				commandBuffer:insert(self:quoteArgument(argument))
			else
				commandBuffer:insert(argument.argument)
			end
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
		tabelizedScriptBuffer:insert(line .. self.newline)
	end
end

function module:appendCommandLineToScript(tabelizedScriptBuffer, ...)
	tabelizedScriptBuffer:insert(self:toShellCommandLine(...))
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
		paths:insert(path)
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


local PosixShellLanguage = halimede.class('PosixShellLanguage', ShellLanguage)

function PosixShellLanguage:initialize()
	ShellLanguage.initialize(self, 'posix', 'Posix', PathStyle.Posix, '\n', nil, '/dev/null', false, 'sh')
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'gsub')
function PosixShellLanguage:_quoteArgument(argument)
	return "'" .. argument:gsub("'", "'\\''") .. "'"
end

ShellLanguage.static.Posix = PosixShellLanguage:new()


local CmdShellLanguage = halimede.class('CmdShellLanguage', ShellLanguage)

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
function CmdShellLanguage:_quoteArgument(argument)
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

-- Windows, Linux, OSX, BSD, POSIX, Other (not supported)
local operatingSystemNamesToShellLanguages = {
	Windows = ShellLanguage.Cmd,
	Linux = ShellLanguage.Posix,
	OSX = ShellLanguage.Posix,
	BSD = ShellLanguage.Posix,
	POSIX = ShellLanguage.Posix
}

local cachedDefault = false
assert.globalTypeIsFunction('pcall')
ShellLanguage.static.default = function()
	if cachedDefault ~= false then
		return cachedDefault
	end
	
	local function determineDefault()
		if type.hasPackageChildFieldOfTypeString('jit', 'os') then
		
			local name = jit.os
			local shellLanguage = operatingSystemNamesToShellLanguages[name]
			if shellLanguage ~= nil then
				return shellLanguage
			end
		end
	
		-- Not the best test; doesn't work for Symbian, can't distinguish OpenVms from RISC OS
		-- Running uname on the PATH works on POSIX systems, but that rules out Windows... and the shell isn't available on Unikernels like RumpKernel
		local folderSeparator = packageConfiguration.folderSeparator
		if folderSeparator == '/' then
			return ShellLanguage.Posix
		elseif folderSeparator == '\\' then
			return ShellLanguage.Cmd
			-- Might be Symbian, too, but that's dead
		elseif folderSeparator == '.' then
			-- Could be OpenVMS, Could be Risc OS
			local ok, result = pcall(require, 'riscos')
			if ok then
				exception.throw("RISC OS (RiscLua) is not yet supported")
			end
			exception.throw("OpenVMS is not yet supported")
		else
			exception.throw("Could not determine ShellLanguage using packageConfiguration folderSeparator '%s'", folderSeparator)
		end
	end
	
	cachedDefault = determineDefault()
	return cachedDefault
end
