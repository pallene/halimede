--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local sibling = halimede.io.shellScript
local type = halimede.type
local isNil = type.isNil
local isBoolean = type.isBoolean
local isString = type.isString
local isNumber = type.isNumber
local isPositiveInteger = type.isPositiveInteger
local hasPackageChildFieldOfTypeString = type.hasPackageChildFieldOfTypeString
local tabelize = halimede.table.tabelize
local unique = halimede.table.unique
local packageConfiguration = halimede.packageConfiguration
local getenv = halimede.getenv
local exception = halimede.exception
local isInstanceOf = halimede.type.isInstanceOf
local Path = halimede.io.paths.Path
local PathStyle = halimede.io.paths.PathStyle
local Relative = halimede.io.paths.PathRelativity.Relative
local ShellArgument = sibling.ShellArgument
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
module.static.execute = executeFunction
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
	
	self:_initializeSpecialDirectory('parentPath', pathStyle.parentDirectory)
	self:_initializeSpecialDirectory('currentPath', pathStyle.currentDirectory)
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

	return self:_toShellCommandStringIncludingRedirections(unpack(arguments))
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
local openBinaryFileForReading = FileHandleStream.openBinaryFileForReading
assert.globalTypeIsFunctionOrCall('pcall')
function module:commandExistsAt(command, path)
	assert.parameterTypeIsString('command', command)
	assert.parameterTypeIsInstanceOf('path', path, Path)
	
	path:assertIsFolderPath('path')
	
	self:_guardCommandIsValid(command)

	local function callback(binaryFileExtensionOrNil)
		local pathToBinary = path:appendFile(command, binaryFileExtensionOrNil)

		local ok, fileHandleStreamOrError = pcall(openBinaryFileForReading, pathToBinary, command)
		if ok then
			fileHandleStreamOrError:close()
			return true, pathToBinary
		end
		return false, nil
	end

	local ok, pathToBinary = self:iterateOverBinaryFileExtensions(callback)
	if ok then
		return ok, pathToBinary
	end

	return false, nil
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:commandIsOnPath(command)
	for _, path in ipairs(self:binarySearchPath()) do
		
		local ok, pathToBinary = self:commandExistsAt(command, path)
		if ok then
			return ok, pathToBinary
		end
	end

	return false, nil
end

function module:_guardCommandIsValid(command)
	if self.pathStyle:isReservedPathElement(command) then
		exception.throw("%s shell script commands such as '%s' are not valid", self.titleCasedName, command)
	end
end

function module:iterateOverBinaryFileExtensions(callback)
	assert.parameterTypeIsFunctionOrCall('callback', callback)

	return self:_iterateOverBinaryFileExtensions(callback)
end

function module:_iterateOverBinaryFileExtensions(callback)
	exception.throw('Abstract Method')
end

function module:commandIsOnPathAndShellIsAvailableToUseIt(command)
	assert.parameterTypeIsString('command', command)
	
	module:_guardCommandIsValid(command)

	if ShellLanguage.shellIsAvailable then
		return self:commandIsOnPath(command)
	else
		return false
	end
end

function module:escapeToPathsStringShellArgument(paths, specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsTable('paths', paths)  -- shell paths
	assert.parameterTypeIsBoolean('specifyCurrentDirectoryExplicitlyIfAppropriate', specifyCurrentDirectoryExplicitlyIfAppropriate)

	local result = tabelize()
	local uniquePaths = unique(paths)
	for _, path in ipairs(uniquePaths) do
		path:escapeToShellArgument(specifyCurrentDirectoryExplicitlyIfAppropriate, self):insertValue(result)
	end

	return ShellArgument:new(result:concat(self.pathSeparator))
end

function module:escapeToShellSafeString(argument)
	if isString(argument) then
		return self:_escapeToShellSafeString(argument)
	end

	assert.parameterTypeIsInstanceOf('argument', argument, ShellArgument)
	return argument.argument
end

function module:quoteEnvironmentVariable(argument)
	assert.parameterTypeIsString('argument', argument)

	return self:_quoteEnvironmentVariable(argument)
end

function module:_escapeToShellSafeString(argument)
	exception.throw('Abstract Method')
end

function module:_quoteEnvironmentVariable(argument)
	exception.throw('Abstract Method')
end

function module:_redirect(fileDescriptor, filePathOrFileDescriptor, symbol)
	local redirection
	if isPositiveInteger(filePathOrFileDescriptor) then
		redirection = '&' .. filePathOrFileDescriptor
	elseif isString(filePathOrFileDescriptor) then
		redirection = self:escapeToShellSafeString(filePathOrFileDescriptor)
	elseif isInstanceOf(filePathOrFileDescriptor, ShellArgument) then
		redirection = filePathOrFileDescriptor.argument
	else
		exception.throw("filePathOrFileDescriptor must be a positive integer (or zero), string or ShellArgument")
	end

	return ShellArgument:new(fileDescriptor .. symbol .. redirection)
end

function module:redirectInput(fileDescriptor, filePathOrFileDescriptor)
	assert.parameterTypeIsPositiveInteger('fileDescriptor', fileDescriptor)

	return self:_redirect(fileDescriptor, filePathOrFileDescriptor, '<')
end

function module:redirectOutput(fileDescriptor, filePathOrFileDescriptor)
	assert.parameterTypeIsPositiveInteger('fileDescriptor', fileDescriptor)

	return self:_redirect(fileDescriptor, filePathOrFileDescriptor, '>')
end

function module:appendOutput(fileDescriptor, filePathOrFileDescriptor)
	assert.parameterTypeIsPositiveInteger('fileDescriptor', fileDescriptor)

	return self:_redirect(fileDescriptor, filePathOrFileDescriptor, '>>')
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

function module:appendStandardOutput(filePathOrFileDescriptor)
	return self:appendOutput(ShellLanguage.standardOut, filePathOrFileDescriptor)
end

function module:appendStandardError(filePathOrFileDescriptor)
	return self:appendOutput(ShellLanguage.standardError, filePathOrFileDescriptor)
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:_toShellCommandStringIncludingRedirections(...)
	local arguments = {...}

	local commandBuffer = tabelize()

	for _, argument in ipairs(arguments) do
		if argument ~= nil then
			local escapedArgumentStringValue
			if isPositiveInteger(argument) then
				escapedArgumentStringValue = '' .. argument
			elseif isString(argument) then
				escapedArgumentStringValue = self:escapeToShellSafeString(argument)
			elseif isInstanceOf(argument, ShellArgument) then
				escapedArgumentStringValue = argument.argument
			else
				exception.throw("argument must be nil (in which case it is ignored), a positive integer (including zero), string or ShellArgument")
			end
			commandBuffer:insert(escapedArgumentStringValue)
		end
	end

	return commandBuffer:concat(' ')
end

function module:appendCommandLineToScript(tabelizedScriptBuffer, ...)
	assert.parameterTypeIsTable('tabelizedScriptBuffer', tabelizedScriptBuffer)
	
	local commandString = self:_toShellCommandStringIncludingRedirections(...)
	tabelizedScriptBuffer:insert(self:terminateShellCommandString(commandString))
	self:_appendCommandLineToScript_applyChecksForNonZeroExitCode(tabelizedScriptBuffer)
end

function module:_appendCommandLineToScript_applyChecksForNonZeroExitCode(tabelizedScriptBuffer)
	exception.throw('Abstract Method')
end

function module:terminateShellCommandString(commandString)
	assert.parameterTypeIsString('commandString', commandString)
	
	return commandString .. self.newline
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

function module:_initializeSpecialDirectory(name, value)
	if value and not value:isEmpty() then
		self[name] = self:relativeFolderPath(value)
	else
		self[name] = nil
	end
end

function module:relativeFolderPath(...)
	return Path:new(self.pathStyle, Relative, nil, {...}, false, nil)
end

function module:relativeFilePath(...)
	return Path:new(self.pathStyle, Relative, nil, {...}, true, nil)
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

-- We really should look at trying to obtain '$SHELL' for commandInterpeterName / Path
function PosixShellLanguage:initialize()
	ShellLanguage.initialize(self, 'posix', 'Posix', PathStyle.Posix, '\n', nil, ':', '/dev/null', false, 'sh')
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'find', 'gsub')
function PosixShellLanguage:_escapeToShellSafeString(argument)
	if argument:find('\0') ~= nil then
		exception.throw("POSIX shell script arguments can not contain ASCII NUL (0x00)")
	end
	return "'" .. argument:gsub("'", "'\\''") .. "'"
end

function PosixShellLanguage:_quoteEnvironmentVariable(argument)
	return '"${' .. argument .. '}"'
end

function PosixShellLanguage:_appendCommandLineToScript_applyChecksForNonZeroExitCode(tabelizedScriptBuffer)
end

function PosixShellLanguage:_iterateOverBinaryFileExtensions(callback)
	return callback(nil)
end

ShellLanguage.static.Posix = PosixShellLanguage:new()


local CmdShellLanguage = halimede.class('CmdShellLanguage', ShellLanguage)

-- We really should look at trying to obtain '%COMSPEC%' for commandInterpeterName / Path
function CmdShellLanguage:initialize()
	ShellLanguage.initialize(self, 'cmd', 'Cmd', PathStyle.Cmd, '\r\n', 'cmd', ';', 'NUL', true, 'CMD')

	self.binaryFileExtensionsCached = nil
	self.nonZeroExitChecksCommandStringLine = self:terminateShellCommandString('IF %ERRORLEVEL% NEQ 0 EXIT %ERRORLEVEL%')
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
function CmdShellLanguage:_escapeToShellSafeString(argument)
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
function CmdShellLanguage:_toShellCommandStringIncludingRedirections(...)
	return 'type NUL && ' .. ShellLanguage._toShellCommandStringIncludingRedirections(self, ...)
end

function CmdShellLanguage:_appendCommandLineToScript_applyChecksForNonZeroExitCode(tabelizedScriptBuffer)
	tabelizedScriptBuffer:insert(self.nonZeroExitChecksCommandStringLine)
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
		if hasPackageChildFieldOfTypeString('ffi', 'os') then
			local name = ffi.os
			local shellLanguage = operatingSystemNamesToShellLanguages[name]
			if shellLanguage ~= nil then
				return shellLanguage
			end
		end

		-- Not the best test; doesn't work for Symbian (which doesn't have a shell), can't distinguish OpenVms from RISC OS
		-- Running uname on the PATH works on POSIX systems, as does ver on Windows (which is a builtin of cmd)... and the shell isn't available on Unikernels like RumpKernel
		local folderSeparator = packageConfiguration.folderSeparator
		if folderSeparator == '/' then
			return ShellLanguage.Posix
		elseif folderSeparator == '\\' then
			-- Might be Symbian, too, but that's dead
			return ShellLanguage.Cmd
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
