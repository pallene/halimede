--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local ourModuleName = 'halimede'
local ourModule = {}

-- Loaded twice for some reason. First time the type is 'userdata'
if package and package.loaded and type then
	if type(package.loaded[ourModuleName]) == 'table' then
		return package.loaded[ourModuleName]
	end
end

module = ourModule
moduleName = ourModuleName
parentModuleName = ''

-- Best efforts for failing if error is missing
if error == nil then
	local errorMessage = essentialGlobalMissingErrorMessage('error')
	if assert ~= nil then
		assert(false, errorMessage)
		return
	end
	if print ~= nil then
		print(errorMessage)
	end
	if os ~= nil then
		if os.exit ~= nil then
			os.exit(1)
			return
		end
	end
	error("Calling non-existent error should cause the Lua environment to die")
	return
end

local function essentialGlobalMissingErrorMessage(globalName)
	return "The essential global '" .. globalName .. "' is not present in the Lua environment"
end

if coroutine == nil then
	--noinspection GlobalCreationOutsideO
	coroutine = {}
end

if package == nil then
	--noinspection GlobalCreationOutsideO
	package = {}
end

if string == nil then
	essentialGlobalMissingError('string')
end

if math == nil then
	--noinspection GlobalCreationOutsideO
	math = {}
end

if table == nil then
	--noinspection GlobalCreationOutsideO
	table = {}
end

-- bit32 as of Lua 5.2; not checked for as added by LuaJIT or as Mike Pall's library as required

if io == nil then
	--noinspection GlobalCreationOutsideO
	io = {}
end

if os == nil then
	--noinspection GlobalCreationOutsideO
	os = {}
end

if debug == nil then
	--noinspection GlobalCreationOutsideO
	debug = {}
end

local function essentialGlobalMissingError(globalName)
	error(essentialGlobalMissingErrorMessage(globalName))
end

if type == nil then
	essentialGlobalMissingError('type')
end

if setmetatable == nil then
	if debug and debug.setmetabletable then
		--noinspection GlobalCreationOutsideO
		setmetatable = debug.setmetatable
	else
		essentialGlobalMissingError('setmetatable')
	end
end

if getmetatable == nil then
	if debug and debug.getmetatable then
		--noinspection GlobalCreationOutsideO
		setmetatable = debug.getmetatable
	else
		essentialGlobalMissingError('getmetatable')
	end
end

if rawget == nil then
	essentialGlobalMissingError('rawget')
end

if rawset == nil then
	essentialGlobalMissingError('rawset')
end

if _G == nil then
	if _ENV then
		--noinspection GlobalCreationOutsideO
		_G = setmetatable({}, {
			_index = _ENV,
			__newindex = ENV
		})
	else
		essentialGlobalMissingError('_G')
	end
end

-- tostring, tonumber can probably be implemented in Pure Lua

if _VERSION == nil then
	--noinspection GlobalCreationOutsideO
	_VERSION = 'Lua 5.1'
end

-- Guard for presence of global assert
if assert == nil then
	--noinspection GlobalCreationOutsideO
	assert = function(value, message)
		if value == false or value == nil then
			local assertionMessage
			if message == nil then
				assertionMessage = 'assertion failed!'
			else
				assertionMessage = message
			end
			error(assertionMessage)
		else
			return value, optionalMessage
		end
	end
end

if string.len == nil then
	function string.len(value)
		return #value
	end
end

-- table.concat, table.insert, table.maxn, table.remove, table.sort are all implementable in pure Lua but tricky to get right


if package.loaded == nil then
	package.loaded = {}
end

if package.preload == nil then
	package.preload = {}
end

-- A default that should work even on Windows (note we use a POSIX separator)
-- Lua 5.2 / 5.3 have an extra line!
if package.config == nil then
	local config
	if _VERSION == 'Lua 5.1' then
		config = [[
/
;
?
!
-
]]
	else
		config = [[
/
;
?
!
-

]]
	end
	package.config = config
end

-- Is overridden by our require logic
if package.path == nil then
	package.path = ''
end

-- Is overridden by our require logic
if package.cpath == nil then
	package.cpath = ''
end

-- Is overridden by our require logic
-- require

-- Is not used
-- module

-- Is not used
-- package.seeall

if package.loadlib == nil then
	package.loadlib = function(libname, funcname)
		error('loadlib is not supported')
	end
end

-- Install ffi for LuaJIT
if ffi == nil then
	ffi = require('ffi')
end

-- Based on http://www.lua.org/extras/5.1/strict.lua but doesn't use the debug library
-- Late detection, but better than no detection at all
-- See also http://lua-users.org/wiki/DetectingUndefinedVariables
local function throwErrorsIfGlobalFieldNotDefined()
	local metatable = getmetatable(_G) or {}

	metatable.__index = function(self, key)
		error("Global '" .. key .. "' is not defined", 2)
	end

	setmetatable(_G, metatable)
end
throwErrorsIfGlobalFieldNotDefined()

local function relativeRequireName(childModuleName)
	return ourModuleName .. '.' .. childModuleName
end

local function createNamedCallableFunction(functionName, actualFunction, module, prefix)
	if prefix == nil then
		prefix = 'function'
	end

	if module == nil then
		module = {}
	end

	if rawget(module, 'name') == nil then
		rawset(module, 'name', functionName)
	end

	if rawget(module, 'functor') == nil then
		rawset(module, 'functor', actualFunction)
	end

	return setmetatable(module, {
		__tostring = function()
			return prefix .. ' ' .. functionName
		end,
		__call = function(self, ...)
			return actualFunction(...)
		end
	})
end



halimede = ourModule



local typeOriginalGlobalFunction = type
local type = {}

local function is(value, typeName)
	return typeOriginalGlobalFunction(value) == typeName
end

local function isNot(value, typeName)
	return typeOriginalGlobalFunction(value) ~= typeName
end

local function isType(typeName)
	return function(value)
		return is(value, typeName)
	end
end

local function isNotType(typeName)
	return function(value)
		return isNot(value, typeName)
	end
end

local function isFunctionTypeOrCallType()
	return function(value)
		if is(value, 'function') then
			return true
		end
		local metatable = getmetatable(value)
		if metatable == nil then
			return false
		end
		return is(metatable.__call, 'function')
	end
end

local function isTypeOrType(typeName1, typeName2)
	return function(value)
		return is(value, typeName1) or is(value, typeName2)
	end
end

local function isTypeOrNil(typeName)
	return function(value)
		return is(value, typeName) or value == nil
	end
end

-- From http://lua-users.org/lists/lua-l/2008-11/msg00106.html
-- Neither function is reliable outside of +/-2^51 in range, but that's way beyond 2^32 for a 32-bit unsigned integer
local function isInteger(value)
	return (value + (2^52 + 2^51)) - (2^52 + 2^51) == value
end

local function isPositiveInteger(value)
	return (value + 2^52) - 2^52 == value
end

local function isIntegerType()
	return function(value)
		return is(value, 'number') and isInteger(value)
	end
end

local function isPositiveIntegerType()
	return function(value)
		return is(value, 'number') and isPositiveInteger(value)
	end
end

local isNil = isType('nil')
type.isNil = isNil

local isNumber = isType('number')
type.isNumber = isNumber

local isString = isType('string')
type.isString = isString

local isBoolean = isType('boolean')
type.isBoolean = isBoolean

local isTable = isType('table')
type.isTable = isTable

local isFunction = isType('function')
type.isFunction = isFunction

local isThread = isType('thread')
type.isThread = isThread

local isUserdata = isType('userdata')
type.isUserdata = isUserdata

local isNotNil = isNotType('nil')
type.isNotNil = isNotNil

local isNotNumber = isNotType('number')
type.isNotNumber = isNotNumber

local isNotString = isNotType('string')
type.isNotString = isNotString

local isNotBoolean = isNotType('boolean')
type.isNotBoolean = isNotBoolean

local isNotTable = isNotType('table')
type.isNotTable = isNotTable

local isNot = isNotType('function')
type.isNot = isNot

local isNotThread = isNotType('thread')
type.isNotThread = isNotThread

local isNotUserdata = isNotType('userdata')
type.isNotUserdata = isNotUserdata

local isFunctionOrCall = isFunctionTypeOrCallType()
type.isFunctionOrCall = isFunctionOrCall

local isTableOrUserdata = isTypeOrType('table', 'userdata')
type.isTableOrUserdata = isTableOrUserdata

local isNumberOrString = isTypeOrType('number', 'string')
type.isNumberOrString = isNumberOrString

local isNumberOrNil = isTypeOrNil('number')
type.isNumberOrNil = isNumberOrNil

local isStringOrNil = isTypeOrNil('string')
type.isStringOrNil = isStringOrNil

local isBooleanOrNil = isTypeOrNil('boolean')
type.isBooleanOrNil = isBooleanOrNil

local isTableOrNil = isTypeOrNil('table')
type.isTableOrNil = isTableOrNil

local isFunctionOrNil = isTypeOrNil('function')
type.isFunctionOrNil = isFunctionOrNil

local isThreadOrNil = isTypeOrNil('thread')
type.isThreadOrNil = isThreadOrNil

local isUserdataOrNil = isTypeOrNil('userdata')
type.isUserdataOrNil = isUserdataOrNil

local isInteger = isIntegerType()
type.isInteger = isInteger

local isPositiveInteger = isPositiveIntegerType()
type.isPositiveInteger = isPositiveInteger

local function hasGlobalOfType(isOfTypeFunction, name)
	local global = rawget(_G, name)
	return isOfTypeFunction(global), global
end

local function hasGlobalOfTypeString(name)
	return hasGlobalOfType(isString, name)
end
type.hasGlobalOfTypeString = hasGlobalOfTypeString

local function hasGlobalOfTypeFunctionOrCall(name)
	return hasGlobalOfType(isFunctionOrCall, name)
end
type.hasGlobalOfTypeFunctionOrCall = hasGlobalOfTypeFunctionOrCall

local function hasGlobalOfTypeTableOrUserdata(name)
	return hasGlobalOfType(isTableOrUserdata, name)
end
type.hasGlobalOfTypeTableOrUserdata = hasGlobalOfTypeTableOrUserdata

local function hasPackageChildFieldOfType(isOfTypeFunction, name, ...)
	local ok, package = hasGlobalOfTypeTableOrUserdata(name)
	if not ok then
		return false
	end

	if not isTableOrUserdata(package) then
		return false
	end

	-- We do not use ipairs() in primitive code
	local childFieldNames = {...}
	local index = 1
	local length = #childFieldNames
	while index <= length do
		local childFieldName = childFieldNames[index]

		local value = package[childFieldName]
		if not isOfTypeFunction(value) then
			return false
		end

		index = index + 1
	end
	return true
end

local function hasPackageChildFieldOfTypeString(name, ...)
	return hasPackageChildFieldOfType(isString, name, ...)
end
type.hasPackageChildFieldOfTypeString = hasPackageChildFieldOfTypeString

local function hasPackageChildFieldOfTypeFunctionOrCall(name, ...)
	return hasPackageChildFieldOfType(isFunctionOrCall, name, ...)
end
type.hasPackageChildFieldOfTypeFunctionOrCall = hasPackageChildFieldOfTypeFunctionOrCall

local function hasPackageChildFieldOfTypeTableOrUserdata(name, ...)
	return hasPackageChildFieldOfType(isTableOrUserdata, name, ...)
end
type.hasPackageChildFieldOfTypeTableOrUserdata = hasPackageChildFieldOfTypeTableOrUserdata



-- WARN: Lua's random number generator is not cryptographically secure
-- For that, we need to wrap CryptGenRandom on Windows and use /dev/urandom on Linux
local function initialiseTheRandomNumberGenerator()
	if hasPackageChildFieldOfTypeFunctionOrCall('math', 'randomseed') and hasPackageChildFieldOfTypeFunctionOrCall('os', 'time') then
		math.randomseed(os.time())
	end
end
initialiseTheRandomNumberGenerator()



local assertOriginalGlobalFunction = assert
local assert = {}

local function withLevel(message, level)
	local errorMessage
	if hasPackageChildFieldOfTypeFunctionOrCall('debug', 'traceback') then
		errorMessage = debug.traceback(message, level)
	else
		errorMessage = message
	end

	error(errorMessage, level)
end
assert.withLevel = withLevel

local function parameterIsNotMessage(parameterName, name)
	return "Parameter '" .. parameterName .. "' is not of type '" .. name .. "'"
end
assert.parameterIsNotMessage = parameterIsNotMessage

local function parameterTypeIs(parameterName, value, isOfTypeFunction, isOfTypeName)
	if isNotString(parameterName) then
		error('Please supply a string parameter name')
	end

	if isOfTypeFunction(value) then
		return
	end
	withLevel(parameterIsNotMessage(parameterName, isOfTypeName), 3)
end

-- Would be a bit odd to use this
function assert.parameterTypeIsNil(parameterName, value)
	return parameterTypeIs(parameterName, value, isNil, 'isNil')
end

function assert.parameterTypeIsNumber(parameterName, value)
	return parameterTypeIs(parameterName, value, isNumber, 'isNumber')
end

function assert.parameterTypeIsString(parameterName, value)
	return parameterTypeIs(parameterName, value, isString, 'isString')
end

function assert.parameterTypeIsBoolean(parameterName, value)
	return parameterTypeIs(parameterName, value, isBoolean, 'isBoolean')
end

function assert.parameterTypeIsTable(parameterName, value)
	return parameterTypeIs(parameterName, value, isTable, 'isTable')
end

function assert.parameterTypeIsFunction(parameterName, value)
	return parameterTypeIs(parameterName, value, isFunction, 'isFunction')
end

function assert.parameterTypeIsThread(parameterName, value)
	return parameterTypeIs(parameterName, value, isThread, 'isThread')
end

function assert.parameterTypeIsUserdata(parameterName, value)
	return parameterTypeIs(parameterName, value, isUserdata, 'isUserdata')
end

function assert.parameterTypeIsFunctionOrCall(parameterName, value)
	return parameterTypeIs(parameterName, value, isFunctionOrCall, 'isFunctionOrCall')
end

function assert.parameterTypeIsTableOrUserdata(parameterName, value)
	return parameterTypeIs(parameterName, value, isTableOrUserdata, 'isTableOrUserdata')
end

function assert.parameterTypeIsNumberOrString(parameterName, value)
	return parameterTypeIs(parameterName, value, isNumberOrString, 'isNumberOrString')
end

function assert.parameterTypeIsNumberOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, isNumberOrNil, 'isNumberOrNil')
end

function assert.parameterTypeIsStringOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, isStringOrNil, 'isStringOrNil')
end

function assert.parameterTypeIsBooleanOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, isBooleanOrNil, 'isBooleanOrNil')
end

function assert.parameterTypeIsTableOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, isTableOrNil, 'isTableOrNil')
end

function assert.parameterTypeIsFunctionOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, isFunctionOrNil, 'isFunctionOrNil')
end

function assert.parameterTypeIsThreadOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, isThreadOrNil, 'isThreadOrNil')
end

function assert.parameterTypeIsUserdataOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, isUserdataOrNil, 'isUserdataOrNil')
end

function assert.parameterTypeIsNotNil(parameterName, value)
	return parameterTypeIs(parameterName, value, isNotNil, 'isNotNil')
end

function assert.parameterTypeIsPositiveInteger(parameterName, value)
	return parameterTypeIs(parameterName, value, isPositiveInteger, 'isPositiveInteger')
end

local function globalTypeIs(isOfTypeFunction, isOfTypeName, ...)
	-- We do not use ipairs() as we may be checking for its existence!
	local names = {...}
	local index = 1
	local length = #names
	while index <= length do
		local name = names[index]
		assert.parameterTypeIsString('name', name)

		local ok, global = hasGlobalOfType(isOfTypeFunction, name)
		if not ok then
			withLevel(essentialGlobalMissingErrorMessage(name), 4)
		end

		index = index + 1
	end
end

function assert.globalTypeIsTable(...)
	return globalTypeIs(isTable, 'isTable', ...)
end

function assert.globalTypeIsFunctionOrCall(...)
	return globalTypeIs(isFunctionOrCall, 'isFunctionOrCall', ...)
end

function assert.globalTypeIsString(...)
	return globalTypeIs(isString, 'isString', ...)
end

local function globalTableHasChieldFieldOfType(isOfTypeFunction, isOfTypeName, name, ...)
	assert.parameterTypeIsFunctionOrCall('isOfTypeFunction', isOfTypeFunction)
	assert.parameterTypeIsString('isOfTypeName', isOfTypeName)
	assert.parameterTypeIsString('name', name)

	local ok, package = hasGlobalOfType(isTableOrUserdata, name)
	if not ok then
		withLevel(essentialGlobalMissingErrorMessage(name), 4)
	end

	local childFieldNames = {...}
	for _, childFieldName in ipairs(childFieldNames) do
		assert.parameterTypeIsString('childFieldName', childFieldName)

		local childField = package[childFieldName]
		if childField == nil then
			withLevel(essentialGlobalMissingErrorMessage(name .. '.' .. childFieldName), 4)
		end
		if not isOfTypeFunction(childField) then
			local qualifiedChildFieldName = "The global '" .. name .. '.' .. childFieldName .. "'"
			withLevel(qualifiedChildFieldName .. " is not a " .. isOfTypeName, 4)
		end
	end
end

function assert.globalTableHasChieldFieldOfTypeTable(name, ...)
	return globalTableHasChieldFieldOfType(isTable, 'isTable', name, ...)
end

function assert.globalTableHasChieldFieldOfTypeFunctionOrCall(name, ...)
	return globalTableHasChieldFieldOfType(isFunctionOrCall, 'isFunctionOrCall', name, ...)
end

function assert.globalTableHasChieldFieldOfTypeString(name, ...)
	return globalTableHasChieldFieldOfType(isString, 'isString', name, ...)
end



assert.globalTableHasChieldFieldOfTypeFunctionOrCall('table', 'insert')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'find', 'sub')
function string.split(value, separator)
	assert.parameterTypeIsString('value', value)
	assert.parameterTypeIsString('separator', separator)

	local result = {}
	local length = #value

	local start
	local finish
	local previousFinish = 1
	while true do
		start, finish = value:find(separator, previousFinish, true)
		if start == nil then
			table.insert(result, value:sub(previousFinish))
			break
		end
		table.insert(result, value:sub(previousFinish, start - 1))
		previousFinish = finish + 1
	end

	return result
end

function string.isEmpty(value)
	assert.parameterTypeIsString('value', value)

	return #value == 0
end

local packageConfigurationMapping = {
	'folderSeparator', -- eg '/' on POSIX
	'luaPathSeparator', -- usually ';' (even on POSIX)
	'substitutionPoint', -- usually '?'
	'executableDirectory',  -- usually '!' (only works on Windows)
	'markToIgnoreTestWhenBuildLuaOpen' -- usually '-'
}

assert.globalTypeIsFunctionOrCall('rawget')
local function addAbiInformationToPackageConfiguration(ffi)
	local abi = rawget(ffi, 'abi')
	if abi == nil then
		abi = function(param)
			return nil
		end
	end
	
	return {
		operatingSystemName = rawget(ffi, 'os'),
		architecture = rawget(ffi, 'arch'),
		is32Bit = abi('32bit'),
		is64Bit = abi('64bit'),
		isLittleEndian = abi('le'),
		isBigEndian = abi('be'),
		hasHardwareFloatingPointUnit = abi('fpu'),
		usesSoftFloatingPointConventions = abi('softfp'),
		usesHardFloatingPointConventions = abi('hardfp'),
		usesEabi = abi('eabi'),
		usesWindowsAbi = abi('win')  -- true for Windows or Cygwin (incl derivatives)
	}
end

assert.globalTypeIsFunctionOrCall('pairs')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'gmatch')
local function initialisePackageConfiguration()
	local configuration = {}

	-- Lua 5.2 / 5.3 have an extra line!
	local maximumKnownLines = #packageConfigurationMapping
	local index = 1
	for line in package.config:gmatch('([^\n]+)') do
		if index > maximumKnownLines then
			break
		end
		configuration[packageConfigurationMapping[index]] = line
		index = index + 1
	end
	
	if hasGlobalOfTypeTableOrUserdata('ffi') then
		configuration.abi = addAbiInformationToPackageConfiguration(ffi)
	else
		configuration.abi = {}
	end
	
	local luaSharedLibraryExtension
	local newline
	local parentFolderExceptForMoreObscureFileSystems = '..'
	local currentFolderExceptForMoreObscureFileSystems = '.'
	local ffiOperatingSystemName = configuration.abi.operatingSystemName
	if ffiOperatingSystemName ~= nil then
		-- Windows, Linux, OSX, BSD, POSIX, Other
		if ffiOperatingSystemName == 'Windows' then
			luaSharedLibraryExtension = 'dll'
			newline = '\r\n'
		else
			-- True even on Mac OS X? (ie is not dylib)
			luaSharedLibraryExtension = 'so'
			newline = '\n'
		end
		
		-- Consoles?
		if ffiOperatingSystemName == 'Other' then
			parentFolderExceptForMoreObscureFileSystems = nil
			currentFolderExceptForMoreObscureFileSystems = nil
		end
	else
		if configuration.folderSeparator == '\\' then
			-- Could be Windows or Symbian; Symbian is effectively dead as of Jan 2016 but is Windows-alike (dll, \r\n, ., .., DOS paths)
			luaSharedLibraryExtension = 'dll'
			newline = '\r\n'
		elseif configuration.folderSeparator == '/' then
			luaSharedLibraryExtension = 'so'
			newline = '\n'
		elseif configuration.folderSeparator == '.' then
			-- Could be OpenVMS, Could be Risc OS
			luaSharedLibraryExtension = nil
			newline = '\n'  -- Strictly speaking OpenVMS doesn't have a newline and RiscOS uses both \n and \r\n
			parentFolderExceptForMoreObscureFileSystems = nil
			currentFolderExceptForMoreObscureFileSystems = nil
		else
			luaSharedLibraryExtension = nil
			newline = '\n'
			parentFolderExceptForMoreObscureFileSystems = nil
			currentFolderExceptForMoreObscureFileSystems = nil
		end
	end
	
	configuration.luaSharedLibraryExtension = luaSharedLibraryExtension
	configuration.newline = newline
	
	configuration.parentFolderExceptForMoreObscureFileSystems = parentFolderExceptForMoreObscureFileSystems
	configuration.currentFolderExceptForMoreObscureFileSystems = currentFolderExceptForMoreObscureFileSystems
	configuration.fileExtensionSeparator = '.'
	
	configuration.isProbablyWindows = function()
		local operatingSystemName = configuration.abi.operatingSystemName
		if operatingSystem ~= nil then
			return operatingSystemName == 'Windows'
		end
		
		return configuration.folderSeparator == '\\'
	end
	
	return configuration
end
local packageConfiguration = initialisePackageConfiguration()


local requireOriginalGlobalFunction = require
local requireFunction

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('table', 'concat')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'format', 'isEmpty', 'find')
assert.globalTypeIsFunctionOrCall('ipairs')
local folderSeparator = packageConfiguration.folderSeparator
local function appendFoldersToPath(...)
	local folders = {...}

	local path
	for index, folder in ipairs(folders) do
		assert.parameterTypeIsString('folder', folder)

		if folder:isEmpty() then
			error(("Folder name at index '%s' is an empty string"):format(index))
		elseif folder:find('\0', 1, true) ~= nil then
			error(("Folder name at index '%s' contains ASCII NUL"):format(index))
		else
			if index == 1 then
				path = folder
			else
				path = path .. folderSeparator .. folder
			end
		end
	end

	return path
end

local parentFolderExceptForMoreObscureFileSystems = packageConfiguration.parentFolderExceptForMoreObscureFileSystems
local currentFolderExceptForMoreObscureFileSystems = packageConfiguration.currentFolderExceptForMoreObscureFileSystems
local folderSeparator = packageConfiguration.folderSeparator
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'match', 'gsub', 'sub', 'isEmpty')
local function findModulesRootPath()
	if _G.modulesRootPathString ~= nil then
		return _G.modulesRootPathString
	end
	
	if parentFolderExceptForMoreObscureFileSystems == nil or currentFolderExceptForMoreObscureFileSystems == nil then
		error("Please specify the global 'modulesRootPathString' in 'lua -e' or your code before require('halimede'), as we can't work out your file system kind")
	end
	
	-- The following logic does not resolve symlinks, unlike the realpath binary
	-- It may rely on the location of halimede/init.lua and the presence of debug.getinfo
	-- It may rely on arg0 being an actual path (this is usually the case, but not necessarily)
	-- It won't work unless we're running on Windows or Posix
	local function dirname(path)
		local currentFolderPath = currentFolderExceptForMoreObscureFileSystems .. folderSeparator

		if path == nil then
			return currentFolderPath
		end

		local regexSeparator
		if folderSeparator == '\\' then
			regexSeparator = '\\\\'
		else
			regexSeparator = folderSeparator
		end

		if path:match('.-' .. regexSeparator .. '.-') then
			local withTrailingSlash = path:gsub('(.*' .. regexSeparator .. ')(.*)', '%1')
			local result = withTrailingSlash:sub(1, #withTrailingSlash - 1)
			if result:isEmpty() then
				return folderSeparator
			end
		else
			return currentFolderPath
		end
	end

	local function findArg0()
		if hasGlobalOfTypeTableOrUserdata('arg') then
			--noinspection ArrayElementZero
			local arg0Value = _G.arg[0]
			if isString(arg0Value) then
				return arg0Value
			end
		end
		if hasPackageChildFieldOfTypeFunctionOrCall('debug', 'getinfo') then
			-- May not be a path, could be compiled C code, etc
			local withLeadingAt = debug.getinfo(initialisePackageConfiguration, 'S').source
			return withLeadingAt:sub(2)
		end
		return nil
	end

	local ourFolderPath = dirname(findArg0())
	return appendFoldersToPath(ourFolderPath, parentFolderExceptForMoreObscureFileSystems)
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'gmatch')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('table', 'insert')
local function parentModuleNameFromModuleName(moduleName)
	local moduleElementNames = {}
	for moduleElementName in moduleName:gmatch('[^%.]+') do
		table.insert(moduleElementNames, moduleElementName)
	end

	local size = #moduleElementNames
	local index = 1
	local parentModuleName = ''
	while index < size do
		if parentModuleName ~= '' then
			parentModuleName = parentModuleName .. '.'
		end
		parentModuleName = parentModuleName .. moduleElementNames[index]
		index = index + 1
	end

	return parentModuleName
end

local searchPathFileExtensions = {
	path = 'lua',
	cpath = packageConfiguration.luaSharedLibraryExtension
}

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'split')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('table', 'insert')
local searchPathGenerators = {
	function(moduleName)
		-- eg halimede.html5 => halimede/html5.lua
		return {packageConfiguration.substitutionPoint}
	end,
	function(moduleName)
		-- eg halimede.html5 => halimede/html5/init.lua
		return {packageConfiguration.substitutionPoint, 'init'}
	end,
	function(moduleName)
		-- eg halimede.html5 => halimede/html5/html5.lua (modname is then irrelevant to searcher)
		local subFolders = moduleName:split('.')
		table.insert(subFolders, subFolders[#subFolders])
		return subFolders
	end,
	function(moduleName)
		-- eg for ljsyscall, checked out as a git submodule 'syscall', require('syscall') => syscall/syscall.lua but also require('syscall.helpers') => syscall/syscall/helpers.lua
		-- This is because ljsyscall is designed to be 'installed' by LuaRocks even though it's pure Lua code...
		-- eg syscall.helpers => syscall/syscall/helpers.lua
		local subFolders = moduleName:split('.')
		table.insert(subFolders, 1, subFolders[1])
		return subFolders
	end,
	function(moduleName)
		-- eg Set => src/Set/init.lua; required for luarocks' install of pure lua https://github.com/wscherphof/lua-set
		return {'src', packageConfiguration.substitutionPoint, 'init'}
	end
}

assert.globalTypeIsFunctionOrCall('ipairs', 'unpack')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('table', 'insert', 'concat')
-- Using a local reference means that we can become detached from other global changes (this matters slightly if we used a default for package.config; highly unlikely)
local fileExtensionSeparator = packageConfiguration.fileExtensionSeparator
local luaPathSeparator = packageConfiguration.luaPathSeparator
local modulesRootPathString = findModulesRootPath()
local function initialiseSearchPaths(moduleNameLocal)
	for key, fileExtension in pairs(searchPathFileExtensions) do
		local paths = {}
		for _, searchPathGenerator in ipairs(searchPathGenerators) do
			local pathPieces = searchPathGenerator(moduleNameLocal)
			table.insert(pathPieces, 1, modulesRootPathString)
			local searchPath = appendFoldersToPath(unpack(pathPieces)) .. fileExtensionSeparator .. fileExtension
			table.insert(paths, searchPath)
		end
		package[key] = table.concat(paths, luaPathSeparator)
	end
end

assert.globalTypeIsFunctionOrCall('getmetatable', 'setmetatable', 'rawget', 'rawset')
local function setUpModule(moduleName, module)
	assert.parameterTypeIsString('moduleName', moduleName)
	assert.parameterTypeIsTableOrNil('module', module)

	if module == nil then
		module = {}
	end

	local metatable = getmetatable(module)
	if metatable == nil then
		metatable = {}
		setmetatable(module, metatable)
	end

	if metatable.__index == nil then
		metatable.__index = function(self, childModuleName)
			assert.parameterTypeIsTable('self', self)
			assert.parameterTypeIsString('childModuleName', childModuleName)

			local fullModuleName = moduleName .. '.' .. childModuleName
			local moduleLoaded = requireFunction(fullModuleName)
			module[childModuleName] = moduleLoaded
			return moduleLoaded
		end
	end

	if metatable.__tostring == nil then
		metatable.__tostring = function()
			return 'module ' .. moduleName
		end
	end

	if rawget(module, 'name') == nil then
		rawset(module, 'name', moduleName)
	end

	return module
end

assert.globalTypeIsFunctionOrCall('getmetatable', 'setmetatable', 'rawset')
local function setAliasedFields(module, aliases)
	assert.parameterTypeIsTable('module', module)
	assert.parameterTypeIsTable('aliases', aliases)

	local metatable = getmetatable(module)
	if metatable == nil then
		metatable = {}
		setmetatable(module, metatable)
	end

	local existingIndex = metatable.__index
	if existingIndex == nil then
		existingIndex = function(self, key)
			return nil
		end
	elseif isTable(existingIndex) then
		existingIndex = function(self, key)
			return existingIndex[key]
		end
	end

	metatable.__index = function(self, key)
		local aliasedToKey = aliases[key]
		if aliasedToKey == nil then
			return existingIndex(self, key)
		end

		return self[aliasedToKey]
	end

	local existingNewIndex = metatable.__newindex
	if existingNewIndex == nil then
		existingNewIndex = function(self, key, value)
			rawset(self, key, value)
		end
	elseif isTable(existingNewIndex) then
		existingNewIndex = function(self, key, value)
			existingNewIndex[key] = value
		end
	end

	metatable.__newindex = function(self, key, value)
		local aliasedToKey = aliases[key]
		if aliasedToKey == nil then
			return existingNewIndex(self, key, value)
		end

		-- Allows other __newindex behaviours
		self[aliasedToKey] = value
	end
end

assert.globalTypeIsFunctionOrCall('ipairs', 'error', 'setmetatable')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('table', 'insert', 'concat')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'isEmpty', 'gsub')
assert.globalTableHasChieldFieldOfTypeTable('package', 'loaded')
-- Lua 5.1 / 5.2 compatibility
local newline = packageConfiguration.newline
local searchers = package.searchers
local loaders = package.loaders
if searchers == nil and loaders == nil then
	searchers = {}
	loaders = searchers
	-- We could continue, but we would be unable to load anything
	error("Please ensure 'package.searchers' or 'package.loaders' exists")
elseif searchers == nil then
	package.searches = nil
	searchers = loaders
elseif loaders == nil then
	package.loaders = nil
	loaders = searchers
end
package.searchers = searchers
setAliasedFields(package, {loaders = 'searchers'})

-- Using a local reference means that we can become detached from other global changes
local loaded = package.loaded
loaded[ourModuleName] = halimede
local aliasedModules = {}
requireFunction = function(modname)
	assert.parameterTypeIsString('modname', modname)

	if modname:isEmpty() then
		error("Please supply a modname to require() that isn't empty")
	end

	local moduleNameLocal = modname

	local alreadyLoadedOrLoadingResult = loaded[moduleNameLocal]
	if alreadyLoadedOrLoadingResult ~= nil then
		return alreadyLoadedOrLoadingResult
	end

	local aliasedModule = aliasedModules[moduleNameLocal]
	if aliasedModule ~= nil then
		loaded[moduleNameLocal] = aliasedModule
		return aliasedModule
	end

	local moduleOriginal = module
	local moduleNameOriginal = moduleName
	local parentModuleNameOriginal = parentModuleName

	-- Prevent a parent that loads a child then having the parent loaded again in an infinite loop
	local moduleLocal = setUpModule(moduleNameLocal)
	loaded[moduleNameLocal] = moduleLocal
	local parentModuleNameLocal = parentModuleNameFromModuleName(moduleNameLocal)

	local function resetModuleGlobals()
		module = moduleOriginal
		moduleName = moduleNameOriginal
		parentModuleName = parentModuleNameOriginal
	end

	module = moduleLocal
	moduleName = moduleNameLocal
	parentModuleName = moduleNameLocal

	initialiseSearchPaths(moduleNameLocal)
	local failures = {}
	for index, searcher in ipairs(searchers) do
		-- filePath only in Lua 5.2+, and not set by the preload searcher
		local moduleLoaderOrFailedToFindExplanationString, filePath = searcher(moduleNameLocal)
		if isFunction(moduleLoaderOrFailedToFindExplanationString) then
			local result = moduleLoaderOrFailedToFindExplanationString()

			local ourResult
			if result == nil then
				ourResult = module
			else
				if isTable(result) then
					ourResult = result
				elseif isFunction(result) then
					ourResult = createNamedCallableFunction(moduleNameLocal, function(self, ...)
						return result(...)
					end, moduleNameLocal, 'modulefunction')
				else
					ourResult = result
				end
			end
			loaded[moduleNameLocal] = ourResult
			resetModuleGlobals()
			return ourResult
		elseif isString(moduleLoaderOrFailedToFindExplanationString) then
			table.insert(failures, moduleLoaderOrFailedToFindExplanationString)
		elseif isNil(moduleLoaderOrFailedToFindExplanationString) then
			-- Possible for searcher at index 4 (the loadall searcher)
			table.insert(failures, newline .. '\t(unknown error)')
		else
			error("Unexpected result type '" .. type(moduleLoaderOrFailedToFindExplanationString) .. "' of searcher at index " .. index .. " for module '" .. moduleNameLocal .. "'")
		end
	end

	loaded[moduleNameLocal] = nil
	resetModuleGlobals()
	error(("Could not load module '%s' because of failures:-%s"):format(moduleNameLocal, table.concat(failures, newline .. '\tor')))
end

local require = createNamedCallableFunction('require', requireFunction, {}, 'modulefunction')


assert.globalTypeIsFunctionOrCall('require')
local function relativeRequire(childModuleName)
	local moduleName = relativeRequireName(childModuleName)
	return requireFunction(moduleName)
end

local function augment(moduleLeafName)
	return relativeRequire('internal.' .. moduleLeafName)
end


setUpModule(ourModuleName, halimede)
halimede.name = ourModuleName

-- Used by middleclass
assert.globalTypeIsFunctionOrCall('setmetatable', 'rawget', 'tostring', 'ipairs', 'pairs')
assert.globalTypeIsFunctionOrCall('assert', 'type')
local middleclass = relativeRequire('middleclass')

assert.globalTypeIsFunctionOrCall('rawset')
local function allowExplicityNilFields(note, metatable, missingIndexFunction)
	assert.parameterTypeIsTable('metatable', metatable)
	assert.parameterTypeIsFunction('missingIndexFunction', missingIndexFunction)

	metatable.___missingIndexFunction = missingIndexFunction
	metatable.___explicitlyNilFields = {}

	local originalIndex = metatable.__index
	local underlyingIndexFunction
	if isNil(originalIndex) then
		underlyingIndexFunction = function(self, key)
			return nil
		end
	elseif isTable(originalIndex) then
		underlyingIndexFunction = function(self, key)
			return originalIndex[key]
		end
	elseif isFunction(originalIndex) then
		underlyingIndexFunction = originalIndex
	else
		error("__index in metatable must be of type nil, table or function")
	end

	metatable.__index = function(self, key)
		if metatable.___explicitlyNilFields[key] then
			return nil
		end

		local value = underlyingIndexFunction(self, key)
		if value ~= nil then
			return value
		end
		return metatable.___missingIndexFunction(self, key)
	end

	local originalNewIndex = metatable.__newindex
	local underlyingNewIndexFunction
	if isNil(originalNewIndex) then
		underlyingNewIndexFunction = function(self, key, value)
			rawset(self, key, value)
		end
	elseif isTable(originalNewIndex) then
		underlyingNewIndexFunction = function(self, key, value)
			originalNewIndex[key] = value
		end
	elseif isFunction(originalNewIndex) then
		underlyingNewIndexFunction = originalNewIndex
	else
		error("__newindex in metatable must be of type nil, table or function")
	end

	metatable.__newindex = function(self, key, value)
		if value == nil then
			metatable.___explicitlyNilFields[key] = true
		else
			metatable.___explicitlyNilFields[key] = nil
			underlyingNewIndexFunction(self, key, value)
		end
	end
end

assert.globalTypeIsFunctionOrCall('tostring')
local function errorClassMissingIndex(name)
	return function(self, key)
		error("Class " .. name .. " does not have static field '" .. tostring(key) .. "'", 3)
	end
end

assert.globalTypeIsFunctionOrCall('tostring')
local function errorInstanceMissingIndex(name)
	return function(self, key)
		error("Instance of " .. name .. " does not have instance field '" .. tostring(key) .. "'", 3)
	end
end

assert.globalTypeIsFunctionOrCall('getmetatable')
local function mutateMiddleclassSoThatMissingFieldsCauseErrors()
	local originalFunction = middleclass.class

	middleclass.class = function(name, super, ...)
		local newClass = originalFunction(name, super, ...)

		local classFieldsMetatable = getmetatable(newClass)
		allowExplicityNilFields('class ' .. name, classFieldsMetatable, errorClassMissingIndex(name))

		newClass.setClassMissingIndex = function(classMissingIndexFunction)
			assert.parameterTypeIsFunctionOrCall('classMissingIndexFunction', classMissingIndexFunction)

			classFieldsMetatable.___missingIndexFunction = classMissingIndexFunction
		end

		local instanceFieldsMetatable = newClass.__instanceDict
		allowExplicityNilFields('instance ' .. name, instanceFieldsMetatable, errorInstanceMissingIndex(name))

		newClass.setInstanceMissingIndex = function(instanceMissingIndexFunction)
			assert.parameterTypeIsFunctionOrCall('instanceMissingIndexFunction', instanceMissingIndexFunction)

			instanceFieldsMetatable.___missingIndexFunction = instanceMissingIndexFunction
		end

		return newClass
	end

	return middleclass
end
local class = mutateMiddleclassSoThatMissingFieldsCauseErrors()

aliasedModules['middleclass'] = class
halimede.class = class
setAliasedFields(halimede, {middleclass = 'class'})

setUpModule(relativeRequireName('require'), require)
halimede.require = require
aliasedModules['require'] = require

setUpModule(relativeRequireName('type'), type)
halimede.type = type
aliasedModules['type'] = type
local isInstanceOf = halimede.class.Object.isInstanceOf
halimede.type.isInstanceOf = isInstanceOf
halimede.type.isObject = function(value)
	isInstanceOf(value, Object)
end

setUpModule(relativeRequireName('assert'), assert)
halimede.assert = assert
aliasedModules['assert'] = assert

halimede.packageConfiguration = packageConfiguration
halimede.createNamedCallableFunction = createNamedCallableFunction
halimede.modulesRootPathString = modulesRootPathString
halimede.allowExplicityNilFields = allowExplicityNilFields

halimede.internal = {}

halimede.setUpModule = setUpModule

augment('getenv')

augment('trace')

augment('getUnderlyingFunctionFromCallable')

augment('moduleclass')

augment('modulefunction')

augment('delegateclass')

return halimede
