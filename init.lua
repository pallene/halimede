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

-- table.concat, table.insert, table.maxn, table.remove, table.sort are all implementable in pure Lua but tricky to right


if package.loaded == nil then
	package.loaded = {}
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

if package.preload == nil then
	package.preload = {}
end

if package.loadlib == nil then
	package.loadlib = function(libname, funcname)
		error('loadlib is not supported')
	end
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

local function createNamedReplacementCallableFunction(functionName)
	return createNamedCallableFunction(relativeRequireName(functionName), _G[functionName], {}, 'modulefunction')
end

halimede = ourModule

local requireOriginalGlobalFunction = require
require = createNamedReplacementCallableFunction('require')

local typeOriginalGlobalFunction = type
type = createNamedReplacementCallableFunction('type')

local assertOriginalGlobalFunction = assert
assert = createNamedReplacementCallableFunction('assert')

local function is(value, typeName)
	return typeOriginalGlobalFunction(value) == typeName
end

local function isType(typeName)
	local functionName = typeName
	return createNamedCallableFunction(functionName, function(value)
		return is(value, typeName)
	end)
end

local function isNotType(typeName)
	local functionName = 'not ' .. typeName
	return createNamedCallableFunction(functionName, function(value)
		return not is(value, typeName)
	end)
end

local function isFunctionTypeOrCallType()
	local functionName = 'function or __call'
	return createNamedCallableFunction(functionName, function(value)
		if is(value, 'function') then
			return true
		end
		local metatable = getmetatable(value)
		if metatable == nil then
			return false
		end
		return is(metatable.__call, 'function')
	end)
end

local function isTypeOrType(typeName1, typeName2)
	local functionName = typeName1 .. ' or ' .. typeName2
	return createNamedCallableFunction(functionName, function(value)
		return is(value, typeName1) or is(value, typeName2)
	end)
end

local function isTypeOrNil(typeName)
	return createNamedCallableFunction(typeName .. ' or nil', function(value)
		return is(value, typeName) or value == nil
	end)
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
	return createNamedCallableFunction('positive integer', function(value)
		return is(value, 'number') and isInteger(value)
	end)
end

local function isPositiveIntegerType()
	return createNamedCallableFunction('positive integer', function(value)
		return is(value, 'number') and isPositiveInteger(value)
	end)
end

type.isNil = isType('nil')
type.isNumber = isType('number')
type.isString = isType('string')
type.isBoolean = isType('boolean')
type.isTable = isType('table')
type.isFunction = isType('function')
type.isThread = isType('thread')
type.isUserdata = isType('userdata')
type.isFunctionOrCall = isFunctionTypeOrCallType()
type.isTableOrUserdata = isTypeOrType('table', 'userdata')
type.isNumberOrString = isTypeOrType('number', 'string')
type.isNumberOrNil = isTypeOrNil('number')
type.isStringOrNil = isTypeOrNil('string')
type.isBooleanOrNil = isTypeOrNil('boolean')
type.isTableOrNil = isTypeOrNil('table')
type.isFunctionOrNil = isTypeOrNil('function')
type.isThreadOrNil = isTypeOrNil('thread')
type.isUserdataOrNil = isTypeOrNil('userdata')
type.isNotNil = isNotType('nil')
type.isInteger = isIntegerType()
type.isPositiveInteger = isPositiveIntegerType()

local function hasGlobalOfType(isOfType, name)
	local global = rawget(_G, name)
	return isOfType(global), global
end

function type.hasGlobalOfTypeString(name)
	return hasGlobalOfType(type.isString, name)
end

function type.hasGlobalOfTypeFunctionOrCall(name)
	return hasGlobalOfType(type.isFunctionOrCall, name)
end

function type.hasGlobalOfTypeTableOrUserdata(name)
	return hasGlobalOfType(type.isTableOrUserdata, name)
end

local function hasPackageChildFieldOfType(isOfType, name, ...)
	local ok, package = type.hasGlobalOfTypeTableOrUserdata(name)
	if not ok then
		return false
	end

	if not type.isTableOrUserdata(package) then
		return false
	end

	-- We do not use ipairs() in primitive code
	local childFieldNames = {...}
	local index = 1
	local length = #childFieldNames
	while index <= length do
		local childFieldName = childFieldNames[index]

		local value = package[childFieldName]
		if not isOfType(value) then
			return false
		end

		index = index + 1
	end
	return true
end

function type.hasPackageChildFieldOfTypeString(name, ...)
	return hasPackageChildFieldOfType(type.isString, name, ...)
end

function type.hasPackageChildFieldOfTypeFunctionOrCall(name, ...)
	return hasPackageChildFieldOfType(type.isFunctionOrCall, name, ...)
end

function type.hasPackageChildFieldOfTypeTableOrUserdata(name, ...)
	return hasPackageChildFieldOfType(type.isTableOrUserdata, name, ...)
end

function assert.withLevel(booleanResult, message, level)
	if booleanResult then
		return
	end

	local errorMessage
	if type.hasPackageChildFieldOfTypeFunctionOrCall('debug', 'traceback') then
		errorMessage = debug.traceback(message, level)
	else
		errorMessage = message
	end

	error(errorMessage, level)
end
local withLevel = assert.withLevel

assert.parameterIsNotATemplate = "Parameter is not a "
function assert.parameterIsNotMessage(parameterName, name)
	return "Parameter '" .. parameterName .. "' is not of type '" .. name .. "'"
end

local function parameterTypeIs(parameterName, value, isOfType)
	if not type.isString(parameterName) then
		error('Please supply a string parameter name')
	end

	withLevel(isOfType(value), assert.parameterIsNotMessage(parameterName, isOfType.name), 3)
end

-- Would be a bit odd to use this
function assert.parameterTypeIsNil(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isNil)
end

function assert.parameterTypeIsNumber(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isNumber)
end

function assert.parameterTypeIsString(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isString)
end

function assert.parameterTypeIsBoolean(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isBoolean)
end

function assert.parameterTypeIsTable(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isTable)
end

function assert.parameterTypeIsFunction(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isFunction)
end

function assert.parameterTypeIsThread(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isThread)
end

function assert.parameterTypeIsUserdata(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isUserdata)
end

function assert.parameterTypeIsFunctionOrCall(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isFunctionOrCall)
end

function assert.parameterTypeIsTableOrUserdata(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isTableOrUserdata)
end

function assert.parameterTypeIsNumberOrString(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isNumberOrString)
end

function assert.parameterTypeIsNumberOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isNumberOrNil)
end

function assert.parameterTypeIsStringOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isStringOrNil)
end

function assert.parameterTypeIsBooleanOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isBooleanOrNil)
end

function assert.parameterTypeIsTableOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isTableOrNil)
end

function assert.parameterTypeIsFunctionOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isFunctionOrNil)
end

function assert.parameterTypeIsThreadOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isThreadOrNil)
end

function assert.parameterTypeIsUserdataOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isUserdataOrNil)
end

function assert.parameterTypeIsNotNil(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isNotNil)
end

function assert.parameterTypeIsPositiveInteger(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isPositiveInteger)
end

local function globalTypeIs(isOfType, ...)
	-- We do not use ipairs() as we may be checking for its existence!
	local names = {...}
	local index = 1
	local length = #names
	while index <= length do
		local name = names[index]
		assert.parameterTypeIsString('name', name)

		local ok, global = hasGlobalOfType(isOfType, name)
		if not ok then
			withLevel(true, essentialGlobalMissingErrorMessage(name), 4)
		end
		withLevel(isOfType(global), "The global '" .. name .. "'" .. " is not a " .. isOfType.name, 4)

		index = index + 1
	end
end

function assert.globalTypeIsTable(...)
	return globalTypeIs(type.isTable, ...)
end

function assert.globalTypeIsFunctionOrCall(...)
	return globalTypeIs(type.isFunctionOrCall, ...)
end

function assert.globalTypeIsString(...)
	return globalTypeIs(type.isString, ...)
end

local function globalTableHasChieldFieldOfType(isOfType, name, ...)
	assert.globalTypeIsTable(name)

	local ok, package = hasGlobalOfType(isOfType, name)
	if not ok then
		withLevel(true, essentialGlobalMissingErrorMessage(name), 4)
	end
	if not type.isTableOrUserdata(package) then
		withLevel(true, essentialGlobalMissingErrorMessage(name), 4)
	end

	local childFieldNames = {...}
	for _, childFieldName in ipairs(childFieldNames) do
		assert.parameterTypeIsString('childFieldName', childFieldName)

		local childField = package[childFieldName]
		local qualifiedChildFieldName = "The global '" .. name .. '.' .. childFieldName .. "'"
		withLevel(childField ~= nil, essentialGlobalMissingErrorMessage(name .. '.' .. childFieldName), 4)
		withLevel(isOfType(childField), qualifiedChildFieldName .. " is not a " .. isOfType.name, 4)
	end
end

function assert.globalTableHasChieldFieldOfTypeTable(name, ...)
	return globalTableHasChieldFieldOfType(type.isTable, name, ...)
end

function assert.globalTableHasChieldFieldOfTypeFunctionOrCall(name, ...)
	return globalTableHasChieldFieldOfType(type.isFunctionOrCall, name, ...)
end

function assert.globalTableHasChieldFieldOfTypeString(name, ...)
	return globalTableHasChieldFieldOfType(type.isString, name, ...)
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

-- WARN: Lua's random number generator is not cryptographically secure
-- For that, we need to wrap CryptGenRandom on Windows and use /dev/urandom on Linux
local function initialiseTheRandomNumberGenerator()
	if type.hasPackageChildFieldOfTypeFunctionOrCall('math', 'randomseed') and type.hasPackageChildFieldOfTypeFunctionOrCall('os', 'time') then
		math.randomseed(os.time())
	end
end
initialiseTheRandomNumberGenerator()

local packageConfigurationMapping = {
	'folderSeparator', -- eg '/' on POSIX
	'luaPathSeparator', -- usually ';' (even on POSIX)
	'substitutionPoint', -- usually '?'
	'executableDirectory',  -- usually '!' (only works on Windows)
	'markToIgnoreTestWhenBuildLuaOpen' -- usually '-'
}

-- Will work OK-ish even on Windows, as '/' is a valid folder separator. However, this is not ideal
local defaultConfigurationIfMissing = {
	folderSeparator = '/',
	luaPathSeparator = ';',
	substitutionPoint = '?',
	executableDirectory = '!',
	markToIgnoreTestWhenBuildLuaOpen = '-'
}

assert.globalTypeIsFunctionOrCall('pairs')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'gmatch')
local function initialisePackageConfiguration()
	local configuration = {}

	local packageConfigurationString
	if type.hasPackageChildFieldOfTypeString('package', 'config') then
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
	else
		for name, value in pairs(defaultConfigurationIfMissing) do
			configuration[name] = value
		end
	end

	local luaSharedLibraryExtension
	local newline
	if type.hasPackageChildFieldOfTypeString('jit', 'os') then
		-- Windows, Linux, OSX, BSD, POSIX, Other
		local name = jit.os
		if name == 'Windows' then
			luaSharedLibraryExtension = 'dll'
			newline = '\r\n'
		else
			-- True even on Mac OS X? (not dylib)
			luaSharedLibraryExtension = 'so'
			newline = '\n'
		end
	else
		-- Doesn't work on Symbian
		if packageConfiguration.folderSeparator == '\\' then
			luaSharedLibraryExtension = 'dll'
			newline = '\r\n'
		else
			luaSharedLibraryExtension = 'so'
			newline = '\n'
		end
	end
	configuration.luaSharedLibraryExtension = luaSharedLibraryExtension
	configuration.newline = newline

	-- True for all bar RISC OS
	configuration.fileExtensionSeparator = '.'

	-- Not true for more obscure File Systems
	configuration.parentFolder = '..'
	configuration.currentFolder = '.'

	return configuration
end
local packageConfiguration = initialisePackageConfiguration()

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

local parentFolder = packageConfiguration.parentFolder
local currentFolder = packageConfiguration.currentFolder
local folderSeparator = packageConfiguration.folderSeparator
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'match', 'gsub', 'sub', 'isEmpty')
local function findModulesRootPath()
	if _G.modulesRootPathString ~= nil then
		return _G.modulesRootPathString
	end

	-- The following logic does not resolve symlinks, unlike the realpath binary
	-- It may rely on the location of halimede/init.lua and the presence of debug.getinfo
	-- It may rely on arg0 being an actual path (this is usually the case, but not necessarily)
	-- It won't work unless we're running on Windows or Posix
	local function dirname(path)
		local currentFolderPath = currentFolder .. folderSeparator

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
		if type.hasGlobalOfTypeTableOrUserdata('arg') then
			--noinspection ArrayElementZero
			local arg0Value = _G.arg[0]
			if type.isString(arg0Value) then
				return arg0Value
			end
		end
		if type.hasPackageChildFieldOfTypeFunctionOrCall('debug', 'getinfo') then
			-- May not be a path, could be compiled C code, etc
			local withLeadingAt = debug.getinfo(initialisePackageConfiguration, 'S').source
			return withLeadingAt:sub(2)
		end
		return nil
	end

	local ourFolderPath = dirname(findArg0())
	return appendFoldersToPath(ourFolderPath, parentFolder)
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

local requireFunction

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
			assert.parameterTypeIsString('moduleName', moduleName)

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
	elseif type.isTable(existingIndex) then
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
	elseif type.isTable(existingNewIndex) then
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
		if type.isFunction(moduleLoaderOrFailedToFindExplanationString) then
			local result = moduleLoaderOrFailedToFindExplanationString()

			local ourResult
			if result == nil then
				ourResult = module
			else
				if type.isTable(result) then
					ourResult = result
				elseif type.isFunction(result) then
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
		elseif type.isString(moduleLoaderOrFailedToFindExplanationString) then
			table.insert(failures, moduleLoaderOrFailedToFindExplanationString)
		elseif type.isNil(moduleLoaderOrFailedToFindExplanationString) then
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
require = createNamedCallableFunction('require', requireFunction, {}, 'modulefunction')


assert.globalTypeIsFunctionOrCall('getmetatable')
local function createSibling()
	local function sibling(siblingModuleElementName)
		assert.parameterTypeIsString('siblingModuleElementName', siblingModuleElementName)

		local grandParentModuleName = parentModuleNameFromModuleName(parentModuleName)
		local requiredModuleName
		if grandParentModuleName == '' then
			requiredModuleName = siblingModuleElementName
		else
			requiredModuleName = grandParentModuleName .. '.' .. siblingModuleElementName
		end
		return require.functor(requiredModuleName)
	end

	local siblingTable = createNamedCallableFunction('sibling', sibling)

	local metatable = getmetatable(siblingTable)
	metatable.__index = function(self, key)
		return sibling(key)
	end

	return siblingTable
end
require.sibling = createSibling()


assert.globalTypeIsFunctionOrCall('require')
local function relativeRequire(childModuleName)
	local moduleName = relativeRequireName(childModuleName)
	return requireFunction(moduleName)
end

local function augment(moduleLeafName)
	return relativeRequire('init.' .. moduleLeafName)
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
	if type.isNil(originalIndex) then
		underlyingIndexFunction = function(self, key)
			return nil
		end
	elseif type.isTable(originalIndex) then
		underlyingIndexFunction = function(self, key)
			return originalIndex[key]
		end
	elseif type.isFunction(originalIndex) then
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
	if type.isNil(originalNewIndex) then
		underlyingNewIndexFunction = function(self, key, value)
			rawset(self, key, value)
		end
	elseif type.isTable(originalNewIndex) then
		underlyingNewIndexFunction = function(self, key, value)
			originalNewIndex[key] = value
		end
	elseif type.isFunction(originalNewIndex) then
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

setUpModule(relativeRequireName('assert'), assert)
halimede.assert = assert
aliasedModules['assert'] = assert

halimede.packageConfiguration = packageConfiguration
halimede.createNamedCallableFunction = createNamedCallableFunction
halimede.modulesRootPathString = modulesRootPathString
halimede.allowExplicityNilFields = allowExplicityNilFields

halimede.init = {}

augment('getenv')

augment('trace')

augment('moduleclass')
halimede.moduleclass = moduleclass

augment('modulefunction')
halimede.modulefunction = modulefunction

augment('delegateclass')
halimede.delegateclass = delegateclass

return halimede
