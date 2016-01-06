--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local type = halimede.type
local isNil = type.isNil
local isBoolean = type.isBoolean
local isString = type.isString
local isNumber = type.isNumber
local hasPackageChildFieldOfTypeString = type.hasPackageChildFieldOfTypeString
local tabelize = halimede.table.tabelize
local unique = halimede.table.unique
local packageConfiguration = halimede.packageConfiguration
local getenv = halimede.getenv
local exception = halimede.exception
local isInstanceOf = halimede.class.Object.isInstanceOf
local Path = halimede.io.paths.Path
local PathStyle = halimede.io.paths.PathStyle
local ShellArgument = require.sibling.ShellArgument
local FileHandleStream = halimede.io.FileHandleStream


local ShellLanguage = halimede.moduleclass('ShellLanguage')

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

-- other things returning (read) file handles are io.open(file) and io.tmpfile()
local validModes = {
	'r',
	'w'
}
local popenFunction
if type.hasPackageChildFieldOfTypeFunctionOrCall('io', 'popen') then
	popenFunction = io.popen
else
	popenFunction = function(command, mode)
		assert.parameterTypeIsString('command', command)
		assert.parameterTypeIsStringOrNil('mode', mode)

		if mode ~= nil then
			if validModes[mode] == nil then
				return nil, "mode '" .. mode .. "' is not valid"
			end
		end

		return nil, 'io.popen is not available'
	end
end

local noRedirection = false
module.static.noRedirection = noRedirection  -- Bizarre but works
module.static.standardIn = 0
module.static.standardOut = 1
module.static.standardError = 2

-- The reason we have a lower case and title case variant is that we avoid the need to use string:lower(), which depends on os.setlocale('all', 'C') to be deterministic, which isn't safe to use (we could be Lua code in a thread or embedded in an application that has already set setlocale())
function module:initialize(lowerCasedName, titleCasedName, pathStyle, newline, shellScriptFileExtensionExcludingLeadingPeriod, pathSeparator, silenced, searchesCurrentPath, commandInterpreterName)
	assert.parameterTypeIsString('lowerCasedName', lowerCasedName)
	assert.parameterTypeIsString('titleCasedName', titleCasedName)
	assert.parameterTypeIsInstanceOf('pathStyle', pathStyle, PathStyle)
	assert.parameterTypeIsString('newline', newline)
	assert.parameterTypeIsStringOrNil('shellScriptFileExtensionExcludingLeadingPeriod', shellScriptFileExtensionExcludingLeadingPeriod)
	assert.parameterTypeIsStringOrNil('pathSeparator', pathSeparator)
	assert.parameterTypeIsString('silenced', silenced)
	assert.parameterTypeIsBoolean('searchesCurrentPath', searchesCurrentPath)
	assert.parameterTypeIsString('commandInterpreterName', commandInterpreterName)

	self.lowerCasedName = lowerCasedName
	self.titleCasedName = titleCasedName
	self.pathStyle = pathStyle
	self.newline = newline
	self.shellScriptFileExtensionExcludingLeadingPeriod = shellScriptFileExtensionExcludingLeadingPeriod
	self.pathSeparator = pathSeparator
	self.silenced = silenced
	self.searchesCurrentPath = searchesCurrentPath
	self.commandInterpreterName = commandInterpreterName

	self.binarySearchPathCached = nil

	self.parentPath = pathStyle.parentPath
	self.currentPath = pathStyle.currentPath
end

function module:appendShellScriptExtension(filePathWithoutFileExtension)
	assert.parameterTypeIsTable('filePathWithoutFileExtension', filePathWithoutFileExtension)

	return filePathWithoutFileExtension:appendFileExtension(self.shellScriptFileExtensionExcludingLeadingPeriod)
end

function module:executeCommandExpectingSuccess(standardIn, standardOut, standardError, ...)
	local success, terminationKind, exitCode, command = self:executeCommand(standardIn, standardOut, standardError, ...)
	if not success then
		exception.throw("Could not execute shell command, returned exitCode '%s' for command (%s)", exitCode, command)
	end
end

assert.globalTypeIsFunctionOrCall('unpack')
function module:_appendRedirectionsAndCreateCommandString(standardIn, standardOut, standardError, ...)
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

	return self:toShellCommand(unpack(arguments))
end

function module:executeCommand(standardIn, standardOut, standardError, ...)
	local command = self:_appendRedirectionsAndCreateCommandString(standardIn, standardOut, standardError, ...)

	-- Lua 5.1: returns an exit code
	-- Lua 5.2 / 5.3: returns true or nil, string ('exit' or 'signal'), exit/signal code
	local exitCodeOrBoolean, terminationKind, exitCode = executeFunction(command)
	if isNil(exitCodeOrBoolean) then
		return false, terminationKind, exitCode, command
	elseif isBoolean(exitCodeOrBoolean) then
		return exitCodeOrBoolean, terminationKind, exitCode, command
	else
		return exitCodeOrBoolean == 0, 'exit', exitCodeOrBoolean, command
	end
end

function module:_popen(standardIn, standardOut, standardError, mode, ...)
	assert.parameterTypeIsStringOrNil('mode', mode)

	local command = self:_appendRedirectionsAndCreateCommandString(standardIn, standardOut, standardError, ...)

	local fileHandle, errorMessage = popenFunction(command, mode)
	if fileHandle == nil then
		exception.throw("Could not popen shell because of error '%s' for command (%s)", errorMessage, command)
	end
	return FileHandleStream:new(fileHandle, 'popen (' .. command .. ')')
end

function module:popenReadingFromSubprocess(standardIn, standardError, ...)
	return self:_popen(standardIn, noRedirection, standardError, 'r', ...)
end

function module:popenWritingToSubprocess(standardOut, standardError, ...)
	return self:_popen(noRedirection, standardOut, standardError, 'w', ...)
end

-- NOTE: This approach is slow, as it opens the executable for reading
-- NOTE: This approach can not determine if a binary is +x (executable) or not
assert.globalTypeIsFunctionOrCall('pcall', 'ipairs')
function module:commandIsOnPath(command)
	assert.parameterTypeIsString('command', command)

	for _, path in ipairs(self:binarySearchPath()) do

		local function callback(fileExtension)
			local pathToBinary = path:appendFile(command, fileExtension)

			local ok, fileHandleStreamOrError = pcall(FileHandleStream.openBinaryFileForReading, pathToBinary, command)
			if ok then
				fileHandleStreamOrError:close()
				return true, pathToBinary
			end
			return false, nil
		end

		local ok, result = self:iterateOverBinaryFileExtensions(callback)
		if ok then
			return ok, result
		end
	end

	return false, nil
end

function module:iterateOverBinaryFileExtensions(callback)
	assert.parameterTypeIsFunctionOrCall('callback', callback)

	return self:_iterateOverBinaryFileExtensions(callback)
end

function module:_iterateOverBinaryFileExtensions(callback)
	exception.throw('Abstract Method')
end

function module:commandIsOnPathAndShellIsAvaiableToUseIt(command)
	assert.parameterTypeIsString('command', command)

	if ShellLanguage.shellIsAvailable then
		return self:commandIsOnPath(command)
	else
		return false
	end
end

function module:toPathsString(paths, specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsTable('paths', paths)  -- shell paths
	assert.parameterTypeIsBoolean('specifyCurrentDirectoryExplicitlyIfAppropriate', specifyCurrentDirectoryExplicitlyIfAppropriate)

	local result = tabelize()
	local uniquePaths = unique(paths)
	for _, path in ipairs(uniquePaths) do
		path:toQuotedShellArgumentX(specifyCurrentDirectoryExplicitlyIfAppropriate, self):insertValue(result)
	end

	return result:concat(self.pathSeparator)
end

function module:toQuotedShellArgument(argument)
	if isString(argument) then
		return self:_toQuotedShellArgument(argument)
	end

	assert.parameterTypeIsInstanceOf('argument', argument, ShellArgument)
	return argument
end

function module:quoteEnvironmentVariable(argument)
	assert.parameterTypeIsString('argument', argument)

	return self:_quoteEnvironmentVariable(argument)
end

function module:_toQuotedShellArgument(argument)
	exception.throw('Abstract Method')
end

function module:_quoteEnvironmentVariable(argument)
	exception.throw('Abstract Method')
end

function module:_redirect(fileDescriptor, filePathOrFileDescriptor, symbol)
	local redirection
	if isNumber(filePathOrFileDescriptor) then
		redirection = '&' .. filePathOrFileDescriptor
	elseif isInstanceOf(filePathOrFileDescriptor, ShellArgument) then
		redirection = filePathOrFileDescriptor.argument
	else
		redirection = self:toQuotedShellArgument(filePathOrFileDescriptor)
	end

	return ShellArgument:new(fileDescriptor .. symbol .. redirection)
end

local function assertParameterIsAcceptableForRedirection(filePathOrFileDescriptor)
	if isNumber(filePathOrFileDescriptor) then
		assert.parameterTypeIsPositiveInteger('filePathOrFileDescriptor', filePathOrFileDescriptor)
		return
	end

	if isString(filePathOrFileDescriptor) then
		return
	end

	if isInstanceOf(filePathOrFileDescriptor, ShellArgument) then
		return
	end
	exception.throw("The parameter 'filePathOrFileDescriptor' is not a positive integer, string or already escaped argument")
end

function module:redirectInput(fileDescriptor, filePathOrFileDescriptor)
	assert.parameterTypeIsPositiveInteger('fileDescriptor', fileDescriptor)
	assertParameterIsAcceptableForRedirection(filePathOrFileDescriptor)

	return self:_redirect(fileDescriptor, filePathOrFileDescriptor, '<')
end

function module:redirectOutput(fileDescriptor, filePathOrFileDescriptor)
	assert.parameterTypeIsPositiveInteger('fileDescriptor', fileDescriptor)
	assertParameterIsAcceptableForRedirection(filePathOrFileDescriptor)

	return self:_redirect(fileDescriptor, filePathOrFileDescriptor, '>')
end

function module:redirectStandardInput(filePathOrFileDescriptor)
	assertParameterIsAcceptableForRedirection(filePathOrFileDescriptor)

	return self:redirectInput(ShellLanguage.standardIn, filePathOrFileDescriptor)
end

function module:redirectStandardOutput(filePathOrFileDescriptor)
	assertParameterIsAcceptableForRedirection(filePathOrFileDescriptor)

	return self:redirectOutput(ShellLanguage.standardOut, filePathOrFileDescriptor)
end

function module:redirectStandardError(filePathOrFileDescriptor)
	assertParameterIsAcceptableForRedirection(filePathOrFileDescriptor)

	return self:redirectOutput(ShellLanguage.standardError, filePathOrFileDescriptor)
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:toShellCommand(...)
	local arguments = {...}

	local commandBuffer = tabelize()

	for _, argument in ipairs(arguments) do
		if argument ~= nil then
			if isString(argument) then
				commandBuffer:insert(self:toQuotedShellArgument(argument))
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

assert.globalTypeIsFunctionOrCall('ipairs')
function module:appendLinesToScript(tabelizedScriptBuffer, ...)
	assert.parameterTypeIsTable('tabelizedScriptBuffer', tabelizedScriptBuffer)

	local lines = {...}
	for _, line in ipairs(lines) do
		assert.parameterTypeIsString('line', line)

		tabelizedScriptBuffer:insert(line .. self.newline)
	end
end

function module:appendCommandLineToScript(tabelizedScriptBuffer, ...)
	assert.parameterTypeIsTable('tabelizedScriptBuffer', tabelizedScriptBuffer)

	tabelizedScriptBuffer:insert(self:toShellCommandLine(...))
	self:_appendCommandLineToScript(tabelizedScriptBuffer, ...)
end

function module:_appendCommandLineToScript(tabelizedScriptBuffer, ...)
	exception.throw('Abstract Method')
end

function module:parentPaths(count)
	assert.parameterTypeIsNumberOrNil('count', count)

	if count == nil then
		return self.parentPath
	end

	assert.parameterTypeIsPositiveInteger('count', count)
	if count == 0 then
		exception.throw("Parameter 'count' can not be zero")
	end

	local parentPath = self.parentPath
	local remaining = count
	while remaining > 1
	do
		parentPath = parentPath:appendRelativePath(self.parentPath)

		remaining = remaining - 1
	end

	return parentPath
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

assert.globalTypeIsFunctionOrCall('ipairs', 'pcall')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'split', 'isEmpty')
function module:uniqueValidPathsFromEnvironmentVariable(environmentVariableName, isFilePath, prependCurrentDirectory)
	assert.parameterTypeIsString('environmentVariableName', environmentVariableName)
	assert.parameterTypeIsBoolean('isFilePath', isFilePath)
	assert.parameterTypeIsBoolean('prependCurrentDirectory', prependCurrentDirectory)

	local paths = tabelize()
	local stringPaths = getenv(environmentVariableName)
	if stringPaths == nil or stringPaths:isEmpty() then
		return paths
	end

	local function parse(potentialPath)
		return self.pathStyle:parse(potentialPath, isFilePath)
	end

	if self.searchesCurrentPath then
		paths:insert(self.currentPath)
	end

	local potentialPaths = stringPaths:split(self.pathSeparator)
	for _, potentialPath in ipairs(potentialPaths) do
		if not potentialPath:isEmpty() then
			local ok, path = pcall(parse, potentialPath)
			if ok then
				paths:insert(path)
			end
		end
	end

	return unique(paths)
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'split')
function module:binarySearchPath()
	if self.binarySearchPathCached == nil then
		self.binarySearchPathCached = self:uniqueValidPathsFromEnvironmentVariable('PATH', false, self.searchesCurrentPath)
	end
	return self.binarySearchPathCached
end


local PosixShellLanguage = halimede.class('PosixShellLanguage', ShellLanguage)

function PosixShellLanguage:initialize()
	ShellLanguage.initialize(self, 'posix', 'Posix', PathStyle.Posix, '\n', nil, ':', '/dev/null', false, 'sh')
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'find', 'gsub')
function PosixShellLanguage:_toQuotedShellArgument(argument)
	if argument:find('\0') ~= nil then
		exception.throw("POSIX shell script arguments can not contain ASCII NUL (0x00)")
	end
	return "'" .. argument:gsub("'", "'\\''") .. "'"
end

function PosixShellLanguage:_quoteEnvironmentVariable(argument)
	return '"${' .. argument .. '}"'
end

function PosixShellLanguage:_appendCommandLineToScript(tabelizedScriptBuffer, ...)
end

function PosixShellLanguage:_iterateOverBinaryFileExtensions(callback)
	return callback(nil)
end

ShellLanguage.static.Posix = PosixShellLanguage:new()


local CmdShellLanguage = halimede.class('CmdShellLanguage', ShellLanguage)

function CmdShellLanguage:initialize()
	ShellLanguage.initialize(self, 'cmd', 'Cmd', PathStyle.Cmd, '\r\n', 'cmd', ';', 'NUL', true, 'cmd')

	self.binaryFileExtensionsCached = nil
end

local slash = '\\'

local cmdCharactersToEscape = {
  ['%'] = '%%',
  ['"'] = '\\"',
}

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'rep')
local function cmdEscaperA(capture1, capture2)
  return slash:rep(2 * #capture1 - 1) .. (capture2 or slash)
end

local function cmdEscaperB(value)
   return value .. value .. '"%"'
end

-- Quoting is a mess in Cmd; these rules only work for cmd.exe /C (it's a per-program thing)
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'match', 'gsub')
function CmdShellLanguage:_toQuotedShellArgument(argument)
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

function CmdShellLanguage:_quoteEnvironmentVariable(argument)
	return '"%' .. argument .. '%"'
end

-- http://lua-users.org/lists/lua-l/2013-11/msg00367.html
function CmdShellLanguage:toShellCommand(...)
	return ShellLanguage.toShellCommand(self, 'type NUL &&', ...)
end

function CmdShellLanguage:_appendCommandLineToScript(tabelizedScriptBuffer, ...)
	self:appendLinesToScript(tabelizedScriptBuffer, 'IF %ERRORLEVEL% NEQ 0 EXIT %ERRORLEVEL%')
end

local DefaultPathExt = ".com; .exe; .bat; .cmd"
CmdShellLanguage.static.DefaultPathExt = DefaultPathExt
assert.globalTypeIsFunctionOrCall('ipairs')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'gsub', 'split')
function CmdShellLanguage:_iterateOverBinaryFileExtensions(callback)
	if self.binaryFileExtensionsCached == nil then
		local pathExt = getenv('PATHEXT')
		if pathExt == nil then
			pathExt = DefaultPathExt
		end
		-- There may be whitespace (eg '; ')
		self.binaryFileExtensionsCached = pathExt:gsub(';[ ]+', ';'):split(';')
	end

	for _, binaryFileExtension in ipairs(self.binaryFileExtensionsCached) do
		local ok, result = callback(binaryFileExtension)
		if ok then
			return true, result
		end
	end
	return false, nil
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
assert.globalTypeIsFunctionOrCall('pcall')
ShellLanguage.static.default = function()
	if cachedDefault ~= false then
		return cachedDefault
	end

	local function determineDefault()
		if hasPackageChildFieldOfTypeString('jit', 'os') then

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
