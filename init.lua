--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local ourModule = {}
local ourModuleName = 'halimede'

rootParentModule = {}
module = rootParentModule
moduleName = ''
parentModuleName = ''
leafModuleName = ''
parentModule = rootParentModule
package.loaded[''] = module
modulesRootPath = ''


local function essentialGlobalMissingErrorMessage(globalName)
	return "The essential global '" .. globalName .. "' is not present in the Lua environment"
end

-- Best efforts for failing if error is missing
if error == nil then
	local errorMessage = essentialGlobalMissingErrorMessage('error')
	if assert ~= nil then
		assert(false, errorMessage)
	end
	if print ~= nil then
		print(errorMessage)
	end
	if os ~= nil then
		if os.exit ~= nil then
			os.exit(1)
		end
	end
	error("Calling non-existent error should cause the Lua environment to die")
end


-- Embedded type module (logically, type.lua, but functionality is needed during load)
-- Embedded assert module (logically, assert.lua, but functionality is needed during load)

local assertModule = {}
package.loaded[ourModuleName .. '.assert'] = assertModule

if type == nil then
	error(essentialGlobalMissingErrorMessage('type'))
end

if setmetatable == nil then
	error(essentialGlobalMissingErrorMessage('setmetatable'))
end

if getmetatable == nil then
	error(essentialGlobalMissingErrorMessage('getmetatable'))
end

local typeModule = {}
package.loaded[ourModuleName .. '.type'] = assertModule

local function NamedFunction(name, functor)
	return setmetatable({
		name = name
	}, {
		__tostring = function()
			return 'function:' .. name
		end,
		__call = function(table, ...)
			return functor(...)
		end
	})
end

local function is(value, name)
	return type(value) == name
end

local function simpleTypeObject(name)
	return NamedFunction(name, function(...)
		local values = {...}
		for _, value in ipairs(values) do
			if is(value, name) then
				return true
			end
		end
		return false
	end)
end

typeModule.isNil = simpleTypeObject('nil')
typeModule.isNumber = simpleTypeObject('number')
typeModule.isString = simpleTypeObject('string')
typeModule.isBoolean = simpleTypeObject('boolean')
typeModule.isTable = simpleTypeObject('table')
typeModule.isFunction = simpleTypeObject('function')
typeModule.isThread = simpleTypeObject('thread')
typeModule.isUserdata = simpleTypeObject('userdata')

local function functionOrCallTypeObject()
	return NamedFunction('function or _call', function(...)
		local values = {...}
		for _, value in ipairs(values) do
			if is(value, 'function') then
				return true
			end
			if is(getmetatable(value).__call, 'function') then
				return true
			end
		end
		return false
	end)
end
typeModule.isFunctionOrCall = functionOrCallTypeObject()

local function multipleTypesObject(name1, name2)
	return NamedFunction(name1 .. ' or ' .. name2, function(...)
		local values = {...}
		for _, value in ipairs(values) do
			if is(value, name1) then
				return true
			end
			if is(value, name2) then
				return true
			end
		end
		return false
	end)
end
typeModule.isTableOrUserdata = multipleTypesObject('table', 'userdata')
typeModule.isNumberOrString = multipleTypesObject('number', 'string')

function typeModule.hasPackageChildFieldOfType(isOfType, name, ...)
	assertModule.parameterTypeIsTable(isOfType)
	assertModule.parameterTypeIsString(name)
	
	local package = _G[name]
	if not typeModule.isTable(package) then
		return false
	end
	
	local package = _G[name]
	
	local childFieldNames = {...}
	for _, childFieldName in ipairs(childFieldNames) do
		assertModule.parameterTypeIsString(childFieldName)
		
		local value = package[childFieldName]
		if not isOfType(value) then
			return false
		end
	end
	
	return true
end

function typeModule.hasPackageChildFieldOfTypeString(name, ...)
	return typeModule.hasPackageChildFieldOfType(typeModule.isString, name, ...)
end

function typeModule.hasPackageChildFieldOfTypeFunctionOrCall(name, ...)
	return typeModule.hasPackageChildFieldOfType(typeModule.isFunctionOrCall, name, ...)
end

function typeModule.hasPackageChildFieldOfTypeTableOrUserdata(name, ...)
	return typeModule.hasPackageChildFieldOfType(typeModule.isTableOrUserdata, name, ...)
end


local type = typeModule
ourModule.type = type






-- Guard for presence of global assert
if assert == nil then
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

function assertModule.withLevel(booleanResult, message, level)
	if booleanResult then
		return
	end
	
	local errorMessage
	if typeModule.hasPackageChildFieldOfTypeFunctionOrCall('debug', 'traceback') then
		errorMessage = debug.traceback(message, level)
	else
		errorMessage = message
	end
	
	error(errorMessage, level)
end
local withLevel = assertModule.withLevel

assertModule.parameterIsNotATemplate = "Parameter is not a "
function assertModule.parameterIsNotMessage(name)
	return "Parameter is not a " .. name
end

local function parameterTypeIs(value, isOfType)
	withLevel(isOfType(value), parameterIsNotMessage(isOfType.name), 4)
end

-- Would be a bit odd to use this
function assertModule.parameterTypeIsNil(value)
	assertModule.parameterTypeIs(value, typeModule.isNil)
end

function assertModule.parameterTypeIsNumber(value)
	return parameterTypeIs(value, typeModule.isNumber)
end

function assertModule.parameterTypeIsString(value)
	return parameterTypeIs(value, typeModule.isString)
end

function assertModule.parameterTypeIsFunction(value)
	return parameterTypeIs(value, typeModule.isBoolean)
end

function assertModule.parameterTypeIsTable(value)
	return parameterTypeIs(value, typeModule.isTable)
end

function assertModule.parameterTypeIsFunction(value)
	return parameterTypeIs(value, typeModule.isFunction)
end

function assertModule.parameterTypeIsThread(value)
	return parameterTypeIs(value, typeModule.isThread)
end

function assertModule.parameterTypeIsUserdata(value)
	return parameterTypeIs(value, typeModule.isUserdata)
end

function assertModule.parameterTypeIsFunctionOrCall(value)
	return parameterTypeIs(value, typeModule.isFunctionOrCall)
end

function assertModule.parameterTypeIsTableOrUserdata(value)
	return parameterTypeIs(value, typeModule.isTableOrUserdata)
end

function assertModule.parameterTypeIsNumberOrString(value)
	return parameterTypeIs(value, typeModule.IsNumberOrString)
end

local function globalTypeIs(isOfType, ...)

	if _G == nil then
		error(essentialGlobalMissingErrorMessage('_G'), 3)
	end
	
	-- We do not use ipairs() as we may be checking for its existence!
	local names = {...}
	local index = 1
	local length = #names
	while index <= length do
		local name = names[index]
		assertModule.parameterTypeIsString(name)
		
		local global = _G[name]
		withLevel(global ~= nil, essentialGlobalMissingErrorMessage(name), 4)
		withLevel(isOfType(global), "The global '" .. name .. "'" .. " is not a " .. isOfType.name, 4)
		
		index = index + 1
	end
end

function assertModule.globalTypeIsTable(...)
	return globalTypeIs(typeModule.isTable, ...)
end

function assertModule.globalTypeIsFunction(...)
	return globalTypeIs(typeModule.isFunction, ...)
end

function assertModule.globalTypeIsString(...)
	return globalTypeIs(typeModule.isString, ...)
end

local function globalTableHasChieldFieldOfType(isOfType, name, ...)
	assertModule.globalTypeIsTable(name)
	
	local package = _G[name]
	
	local childFieldNames = {...}
	for _, childFieldName in ipairs(childFieldNames) do
		assertModule.parameterTypeIsString(childFieldName)
		
		local childField = package[childFieldName]
		local qualifiedChildFieldName = "The global '" .. name .. '.' .. childFieldName .. "'"
		withLevel(childField ~= nil, essentialGlobalMissingErrorMessage(name .. '.' .. childFieldName), 4)
		withLevel(isOfType(childField), qualifiedChildFieldName .. " is not a " .. isOfType.name, 4)
	end
end

function assertModule.globalTableHasChieldFieldOfTypeTable(name, ...)
	return globalTableHasChieldFieldOfType(typeModule.isTable, name, ...)
end

function assertModule.globalTableHasChieldFieldOfTypeFunction(name, ...)
	return globalTableHasChieldFieldOfType(typeModule.isFunction, name, ...)
end

function assertModule.globalTableHasChieldFieldOfTypeString(name, ...)
	return globalTableHasChieldFieldOfType(typeModule.isString, name, ...)
end

assertModule.globalTypeIsFunction(
	'assert',
	'error',
	'ipairs',
	'pairs',
	'pcall',
	'select',
	'setmetatable',
	'type',
	'unpack',
	'xpcall'
)

assertModule.globalTypeIsTable(
	'_G',
	'package',
	'string',
	'table'
)

local assert = assertModule
ourModule.assert = assert



assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert')
assert.globalTableHasChieldFieldOfTypeFunction('string', 'find', 'sub')
function string.split(value, separator)
	assert.parameterTypeIsString(value)
	assert.parameterTypeIsString(separator)
	
	local result = {}
	local length = value:len()
	
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

assert.globalTableHasChieldFieldOfTypeFunction('string', 'len')
function string.isEmpty(value)
	assert.parameterTypeIsString(value)
	
	return value:len() == 0
end
	

assert.globalTableHasChieldFieldOfTypeFunction('string', 'gmatch')
local function initialisePackageConfiguration()
	
	local packageConfigurationMapping = {
		'folderSeparator', -- eg '/' on POSIX
		'pathSeparator', -- usually ';' (even on POSIX)
		'substitutionPoint', -- usually '?'
		'executableDirectory',  -- usually '!' (only works on Windows)
		'markToIgnoreTestWhenBuildLuaOpen' -- usually '-'
	}
	
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
	
	return configuration
end
assert.globalTableHasChieldFieldOfTypeString('package', 'config')
ourModule.packageConfiguration = initialisePackageConfiguration()
local packageConfiguration = ourModule.packageConfiguration

local function detectOperatingSystemDetails()
	
	local operatingSystemDetailsPOSIX = {
		isPosix = true,
		isWindows = false,
		name = 'POSIX',
		sharedLibraryExtension = 'so',
		luaSharedLibraryExtension = 'so',
		sharedLibraryPrefix = 'lib'
	}
	
	local operatingSystemDetailsWindows = {
		isPosix = false,
		isWindows = true,
		name = 'Windows',
		sharedLibraryExtension = 'dll',
		luaSharedLibraryExtension = 'dll',
		sharedLibraryPrefix = ''
	}
	
	if not type.hasPackageChildFieldOfTypeString('jit', 'os') then
		if packageConfiguration.folderSeparator == '\\' then
			return operatingSystemDetailsWindows
		else
			return operatingSystemDetailsPOSIX
		end
	end
	
	-- Windows, Linux, OSX, BSD, POSIX, Other
	local name = jit.os
	if name == 'Windows' then
		return operatingSystemDetailsWindows
	else
		operatingSystemDetailsPOSIX.name = name
		if name == 'OSX' then
			operatingSystemDetailsPOSIX.sharedLibraryExtension = 'dylib'
		end
		return operatingSystemDetailsPOSIX
	end
end
ourModule.operatingSystemDetails = detectOperatingSystemDetails()
local operatingSystemDetails = ourModule.operatingSystemDetails

assert.globalTableHasChieldFieldOfTypeFunction('string', 'match', 'gsub', 'sub')
function ourModule.dirname(path, folderSeparator)
	assert.parameterTypeIsString(path)
	if folderSeparator == nil then
		folderSeparator = packageConfiguration.folderSeparator
	else
		assert.parameterTypeIsString(folderSeparator)
	end
	
	local regexSeparator
	if folderSeparator == '\\' then
		regexSeparator = '\\\\'
	else
		regexSeparator = folderSeparator
	end
	
	if path:match('.-' .. regexSeparator .. '.-') then
		local withTrailingSlash = path:gsub('(.*' .. regexSeparator .. ')(.*)', '%1')
		return withTrailingSlash:sub(1, #withTrailingSlash - 1)
	else
		return '.'
	end
end
local dirname = ourModule.dirname

assert.globalTableHasChieldFieldOfTypeFunction('string', 'match', 'gsub')
function ourModule.basename(path, folderSeparator)
	assert.parameterTypeIsString(path)
	if folderSeparator == nil then
		folderSeparator = packageConfiguration.folderSeparator
	else
		assert.parameterTypeIsString(folderSeparator)
	end
	
	local regexSeparator
	if folderSeparator == '\\' then
		regexSeparator = '\\\\'
	else
		regexSeparator = folderSeparator
	end
	
	if path:match('.-' .. regexSeparator .. '.-') then
		return path:gsub('(.*' .. regexSeparator .. ')(.*)', '%2')
	else
		return path
	end
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'sub')
function ourModule.findArg0()
	if typeModule.isTable(arg) and typeModule.isString(arg[0]) then
		return arg[0]
	else
		if typeModule.hasPackageChildFieldOfTypeFunctionOrCall('debug', 'getinfo') then
			-- May not be a path, could be compiled C code, etc
			local withLeadingAt = debug.getinfo(initialisePackageConfiguration, 'S').source
			return withLeadingAt:sub(2)
		else
			return ''
		end
	end
end
local findArg0 = ourModule.findArg0

-- Please note the absolute path '/' is modelled as ''
assert.globalTableHasChieldFieldOfTypeFunction('table', 'concat')
assert.globalTableHasChieldFieldOfTypeFunction('string', 'format', 'isEmpty')
assert.globalTypeIsFunction('ipairs')
function ourModule.concatenateToPath(folders)
	assert.parameterTypeIsTable(folders)
	
	local folderSeparator = packageConfiguration.folderSeparator
	
	local path = ''
	for index, folder in ipairs(folders) do
		assert.parameterTypeIsString(folder)
		
		if folder:isEmpty() then
			if index == 1 then
				path = folderSeparator
			else
				error(("Folder name at index '%s' is an empty string; only that at index 1 may be on POSIX systems"):format(index))
			end
		elseif folder:match('\0') ~= nil then
			error(("Folder name at index '%s' contains ASCII NUL"):format(index))
		else
			path = path .. folderSeparator .. folder
		end
	end
	
	return path
end
local concatenateToPath = ourModule.concatenateToPath

-- Ideally, we need to use realpath to resolve symlinks
local function findOurFolderPath()
	return dirname(findArg0())
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'gmatch')
assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert')
function ourModule.parentModuleNameFromModuleName(moduleName)
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
	
	return parentModuleName, moduleElementNames[size]
end
local parentModuleNameFromModuleName = ourModule.parentModuleNameFromModuleName

local function requireParentModuleFirst(ourParentModuleName)
	if ourParentModuleName == '' then
		return rootParentModule
	else
		-- Load the parent; recursion is prevented by checking package.loaded
		return require(ourParentModuleName)
	end
end

assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert')
local searchPathGenerators = {
	function(moduleName)
		return packageConfiguration.substitutionPoint
	end,
	function(moduleName)
		return packageConfiguration.substitutionPoint, 'init'
	end,
	function(moduleName)
		-- eg halimede.html5 => halimede/html5/html5.lua (modname is then irrelevant to searcher)
		local subFolders = moduleName:split('.')
		table.insert(subFolders, subFolders[#subFolders])
		return unpack(subFolders)
	end,
	function(moduleName)
		-- eg for ljsyscall, checked out as a git submodule 'syscall', require('syscall') => syscall/syscall.lua but also require('syscall.helpers') => syscall/syscall/helpers.lua
		-- This is because ljsyscall is designed to be 'installed' by LuaRocks even though it's pure Lua code...
		local subFolders = moduleName:split('.')
		table.insert(subFolders, 1, subFolders[1])
		return unpack(subFolders)
	end	
}

assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert', 'concat')
local function initialiseSearchPaths(moduleNameLocal, searchPathGenerators)

	local folderSeparator = packageConfiguration.folderSeparator
	local pathSeparator = packageConfiguration.pathSeparator
	
	local mappings = {
		path = 'lua',
		cpath = operatingSystemDetails.luaSharedLibraryExtension
	}	
	
	for key, fileExtension in pairs(mappings) do
		local paths = {}
		for _, searchPathGenerator in ipairs(searchPathGenerators) do
			table.insert(paths, concatenateToPath({modulesRootPath, searchPathGenerator(moduleNameLocal)) .. '.' .. fileExtension})
		end
		package[key] = table.concat(paths, pathSeparator)
	end
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'gsub')
local function usefulRequire(moduleNameLocal, loaded, searchers, folderSeparator)
	
	local alreadyLoadedOrLoadingResult = loaded[moduleNameLocal]
	if alreadyLoadedOrLoadingResult ~= nil then
		return alreadyLoadedOrLoadingResult
	end
	
	local moduleOriginal = module
	local moduleNameOriginal = moduleName
	local parentModuleNameOriginal = parentModuleName
	local leafModuleNameOriginal = leafModuleName
	local parentModuleOriginal = parentModule
	
	-- Prevent a parent that loads a child then having the parent loaded again in an infinite loop
	local moduleLocal = {}
	loaded[moduleNameLocal] = moduleLocal
	local parentModuleNameLocal, leafModuleNameLocal = parentModuleNameFromModuleName(moduleNameLocal)
	local parentModuleLocal = requireParentModuleFirst(parentModuleNameLocal)
	
	local function resetModuleGlobals()
		module = moduleOriginal
		moduleName = moduleNameOriginal
		parentModuleName = parentModuleNameOriginal
		leadModuleName = leafModuleNameOriginal
		parentModule = parentModuleOriginal
	end
	
	module = moduleLocal
	moduleName = moduleNameLocal
	parentModuleName = moduleNameLocal
	leafModuleName = leafModuleNameLocal
	parentModule = loaded[parentModuleNameLocal]
	
	initialiseSearchPaths(moduleNameLocal, searchPathGenerators)
	for _, searcher in ipairs(searchers) do
		-- filePath only in Lua 5.2+, and not set by the preload searcher
		local moduleLoaderOrFailedToFindExplanationString, filePath = searcher(moduleNameLocal)
		if typeModule.isFunction(moduleLoaderOrFailedToFindExplanationString) then
			local result = moduleLoaderOrFailedToFindExplanationString()
		
			local ourResult
			if result == nil then
				ourResult = module
			else
				if typeModule.isTable(result) then
					ourResult = result
				else
					ourResult = {result}
				end
			end
			loaded[moduleNameLocal] = ourResult
			resetModuleGlobals()
			return ourResult
		end
	end
	
	loaded[moduleNameLocal] = nil
	resetModuleGlobals()
	error(("Could not load module '%s' "):format(moduleNameLocal))
end

-- Lua 5.1 / 5.2 compatibility
local searchers = package.searchers
if searchers == nil then
	searchers = package.loaders
end
if searchers == nil then
	error("Please ensure 'package.searchers' or 'package.loaders' exists")
end

local loaded = package.loaded
local folderSeparator = packageConfiguration.folderSeparator

assert.globalTableHasChieldFieldOfTypeFunction('string', 'len')
assert.globalTableHasChieldFieldOfTypeTable('package', 'loaded')
function require(modname)
	assert.parameterTypeIsString(modname)
	
	if modname:len() == 0 then
		error("Please supply a modname to require() that isn't empty")
	end
	
	return usefulRequire(modname, loaded, searchers, packageConfiguration)
end


-- Support being require'd ourselves
if moduleName ~= '' then
	return ourModule
end

modulesRootPath = concatenateToPath({findOurFolderPath(), '..'})
package.loaded[ourModuleName] = ourModule
require(ourModuleName .. '.init.trace')
require(ourModuleName .. '.init.requireChild')
require(ourModuleName .. '.init.requireSibling')
require(ourModuleName .. '.init.augmentAssertWithMiddleclass')

local class = require(ourModuleName .. '.middleclass')
assert.globalTypeIsFunction('pairs', 'setmetatable', 'getmetatable')
function moduleclass(...)
	local newClass = class(...)
	
	local moduleClass = module
	for key, value in pairs(newClass) do
		moduleClass[key] = newClass[key]
	end
	setmetatable(moduleClass, getmetatable(newClass))
	
	return moduleClass
end
