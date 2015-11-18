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

local function essentialGlobalMissingError(globalName)
	error(essentialGlobalMissingErrorMessage(globalName))
end

if type == nil then
	essentialGlobalMissingError('type')
end

if setmetatable == nil then
	essentialGlobalMissingError('setmetatable')
end

if getmetatable == nil then
	essentialGlobalMissingError('getmetatable')
end

if _G == nil then
	essentialGlobalMissingError('_G')
end

-- tostring, tonumber can probably be implemented in Pure Lua

if _VERSION == nil then
	_VERSION = 'Lua 5.1'
end

if string == nil then
	essentialGlobalMissingError('string')
end

if string.len == nil then
	function string.len(value)
		return #value
	end
end

if math == nil then
	math = {}
end

if coroutine == nil then
	coroutine = {}
end

if os == nil then
	os = {}
end

if debug == nil then
	debug = {}
end

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

if table == nil then
	table = {}
end

-- table.concat, table.insert, table.maxn, table.remove, table.sort are all implementable in pure Lua but tricky to right

if package == nil then
	package = {}
end

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

local typeOriginalGlobalFunction = type
type = setmetatable({}, {
	__tostring = function()
		return 'function:type'
	end,
	__call = function(table, ...)
		return typeOriginalGlobalFunction(...)
	end
})

local assertOriginalGlobalFunction = assert
assert = setmetatable({}, {
	__tostring = function()
		return 'function:assert'
	end,
	__call = function(table, ...)
		return assertOriginalGlobalFunction(...)
	end
})

function assert.NamedFunction(name, functor)
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
local NamedFunction = assert.NamedFunction

local function is(value, name)
	return typeOriginalGlobalFunction(value) == name
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

type.isNil = simpleTypeObject('nil')
type.isNumber = simpleTypeObject('number')
type.isString = simpleTypeObject('string')
type.isBoolean = simpleTypeObject('boolean')
type.isTable = simpleTypeObject('table')
type.isFunction = simpleTypeObject('function')
type.isThread = simpleTypeObject('thread')
type.isUserdata = simpleTypeObject('userdata')

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
type.isFunctionOrCall = functionOrCallTypeObject()

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
type.isTableOrUserdata = multipleTypesObject('table', 'userdata')
type.isNumberOrString = multipleTypesObject('number', 'string')

local function isTypeOrNil(name)
	return NamedFunction(name .. ' or nil', function(...)
		local values = {...}
		for _, value in ipairs(values) do
			if value == nil then
				return true
			end
			return is(value, name)
		end
		return false
	end)
end
type.isStringOrNil = isTypeOrNil('string')
type.isBooleanOrNil = isTypeOrNil('boolean')

function type.hasPackageChildFieldOfType(isOfType, name, ...)
	assert.parameterTypeIsTable('isOfType', isOfType)
	assert.parameterTypeIsString('name', name)
	
	local package = _G[name]
	if not type.isTable(package) then
		return false
	end
	
	local package = _G[name]
	
	local childFieldNames = {...}
	for _, childFieldName in ipairs(childFieldNames) do
		assert.parameterTypeIsString('childFieldName', childFieldName)
		
		local value = package[childFieldName]
		if not isOfType(value) then
			return false
		end
	end
	
	return true
end

function type.hasPackageChildFieldOfTypeString(name, ...)
	return type.hasPackageChildFieldOfType(type.isString, name, ...)
end

function type.hasPackageChildFieldOfTypeFunctionOrCall(name, ...)
	return type.hasPackageChildFieldOfType(type.isFunctionOrCall, name, ...)
end

function type.hasPackageChildFieldOfTypeTableOrUserdata(name, ...)
	return type.hasPackageChildFieldOfType(type.isTableOrUserdata, name, ...)
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
	withLevel(isOfType(value), assert.parameterIsNotMessage(parameterName, isOfType.name), 4)
end

-- Would be a bit odd to use this
function assert.parameterTypeIsNil(parameterName, value)
	assert.parameterTypeIs(parameterName, value, type.isNil)
end

function assert.parameterTypeIsNumber(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isNumber)
end

function assert.parameterTypeIsString(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isString)
end

function assert.parameterTypeIsBoolean(parameterName, value)
	assert.parameterTypeIs(parameterName, value, type.isBoolean)
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

function assert.parameterTypeIsStringOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isStringOrNil)
end

function assert.parameterTypeIsBooleanOrNil(parameterName, value)
	return parameterTypeIs(parameterName, value, type.isBooleanOrNil)
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
		assert.parameterTypeIsString('name', name)
		
		local global = _G[name]
		withLevel(global ~= nil, essentialGlobalMissingErrorMessage(name), 4)
		withLevel(isOfType(global), "The global '" .. name .. "'" .. " is not a " .. isOfType.name, 4)
		
		index = index + 1
	end
end

function assert.globalTypeIsTable(...)
	return globalTypeIs(type.isTable, ...)
end

function assert.globalTypeIsFunction(...)
	return globalTypeIs(type.isFunction, ...)
end

function assert.globalTypeIsFunctionOrCall(...)
	return globalTypeIs(type.isFunctionOrCall, ...)
end

function assert.globalTypeIsString(...)
	return globalTypeIs(type.isString, ...)
end

local function globalTableHasChieldFieldOfType(isOfType, name, ...)
	assert.globalTypeIsTable(name)
	
	local package = _G[name]
	
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

function assert.globalTableHasChieldFieldOfTypeFunction(name, ...)
	return globalTableHasChieldFieldOfType(type.isFunction, name, ...)
end

function assert.globalTableHasChieldFieldOfTypeString(name, ...)
	return globalTableHasChieldFieldOfType(type.isString, name, ...)
end

assert.globalTypeIsTable('string')
assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert')
assert.globalTableHasChieldFieldOfTypeFunction('string', 'len', 'find', 'sub')
function string.split(value, separator)
	assert.parameterTypeIsString('value', value)
	assert.parameterTypeIsString('separator', separator)
	
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

assert.globalTypeIsTable('string')
assert.globalTableHasChieldFieldOfTypeFunction('string', 'len')
function string.isEmpty(value)
	assert.parameterTypeIsString('value', value)
	
	return value:len() == 0
end

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

assert.globalTypeIsFunction('pairs')
assert.globalTableHasChieldFieldOfTypeFunction('string', 'gmatch')
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
	if type.hasPackageChildFieldOfTypeString('jit', 'os') then
		-- Windows, Linux, OSX, BSD, POSIX, Other
		local name = jit.os
		if name == 'Windows' then
			luaSharedLibraryExtension = 'dll'
		else
			-- True even on Mac OS X? (not dylib)
			luaSharedLibraryExtension = 'so'
		end
	else
		-- Doesn't work on Symbian
		if packageConfiguration.folderSeparator == '\\' then
			luaSharedLibraryExtension = 'dll'
		else
			luaSharedLibraryExtension = 'so'
		end
	end
	configuration.luaSharedLibraryExtension = luaSharedLibraryExtension
	
	-- True for all bar RISC OS
	configuration.fileExtensionSeparator = '.'
	
	-- Not true for more obscure File Systems
	configuration.parentFolder = '..'
	configuration.currentFolder = '.'
	
	return configuration
end
local packageConfiguration = initialisePackageConfiguration()

assert.globalTableHasChieldFieldOfTypeFunction('table', 'concat')
assert.globalTableHasChieldFieldOfTypeFunction('string', 'format', 'isEmpty', 'find')
assert.globalTypeIsFunction('ipairs')
local folderSeparator = packageConfiguration.folderSeparator
local function concatenateToPath(...)
	local folders = {...}
	
	local path = ''
	for index, folder in ipairs(folders) do
		assert.parameterTypeIsString('folder', folder)
		
		if folder:isEmpty() then
			if index == 1 then
				path = folderSeparator
			else
				error(("Folder name at index '%s' is an empty string; only that at index 1 may be on POSIX systems"):format(index))
			end
		elseif folder:find('\0', 1, true) ~= nil then
			error(("Folder name at index '%s' contains ASCII NUL"):format(index))
		else
			path = path .. folderSeparator .. folder
		end
	end
	
	return path
end

local parentFolder = packageConfiguration.parentFolder
local currentFolder = packageConfiguration.currentFolder
local folderSeparator = packageConfiguration.folderSeparator
assert.globalTableHasChieldFieldOfTypeFunction('string', 'match', 'gsub', 'sub')
local function findModulesRootPath()
	if _G.modulesRootPath ~= nil then
		return _G.modulesRootPath
	end

	local function dirname(path)
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
			return currentFolder
		end
	end

	local function findArg0()
		if type.isTable(arg) and type.isString(arg[0]) then
			return arg[0]
		else
			if type.hasPackageChildFieldOfTypeFunctionOrCall('debug', 'getinfo') then
				-- May not be a path, could be compiled C code, etc
				local withLeadingAt = debug.getinfo(initialisePackageConfiguration, 'S').source
				return withLeadingAt:sub(2)
			else
				return ''
			end
		end
	end
	
	-- Does not resolve symlinks, unlike the realpath binary
	local ourFolderPath = dirname(findArg0())
	return concatenateToPath(ourFolderPath, parentFolder)
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'gmatch')
assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert')
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
	
	return parentModuleName, moduleElementNames[size]
end

-- assert.globalTypeIsFunction('require')
local function requireParentModuleFirst(ourParentModuleName)
	if ourParentModuleName == '' then
		return rootParentModule
	else
		-- Load the parent; recursion is prevented by checking package.loaded
		return require(ourParentModuleName)
	end
end

local searchPathFileExtensions = {
	path = 'lua',
	cpath = packageConfiguration.luaSharedLibraryExtension
}

assert.globalTableHasChieldFieldOfTypeFunction('string', 'split')
assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert')
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
	end	
}

assert.globalTypeIsFunction('ipairs')
assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert', 'concat')
-- Using a local reference means that we can become detached from other global changes (this matters slightly if we used a default for package.config; highly unlikely)
local fileExtensionSeparator = packageConfiguration.fileExtensionSeparator
local luaPathSeparator = packageConfiguration.luaPathSeparator
local modulesRootPath = findModulesRootPath()
local function initialiseSearchPaths(moduleNameLocal)
	for key, fileExtension in pairs(searchPathFileExtensions) do
		local paths = {}
		for _, searchPathGenerator in ipairs(searchPathGenerators) do
			local pathPieces = searchPathGenerator(moduleNameLocal)
			table.insert(pathPieces, 1, modulesRootPath)
			local searchPath = concatenateToPath(pathPieces) .. fileExtensionSeparator .. fileExtension
			table.insert(paths, searchPath)
		end
		package[key] = table.concat(paths, luaPathSeparator)
	end
end

local function relativeRequireName(childModuleName)
	return ourModuleName .. '.' .. childModuleName
end

assert.globalTypeIsFunction('ipairs', 'error')
assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert', 'concat')
assert.globalTableHasChieldFieldOfTypeFunction('string', 'isEmpty', 'gsub')
assert.globalTableHasChieldFieldOfTypeTable('package', 'loaded')
-- Lua 5.1 / 5.2 compatibility (a good solution uses a metatable to keep references in sync)
local searchers = package.searchers
local loaders = package.loaders
if searchers == nil and loaders == nil then
	searchers = {}
	loaders = searchers
	-- We could continue, but we would be unable to load anything
	error("Please ensure 'package.searchers' or 'package.loaders' exists")
elseif searchers == nil then
	searchers = loaders
elseif loaders == nil then
	loaders = searchers	
end
-- Using a local reference means that we can become detached from other global changes
local loaded = package.loaded
loaded[''] = rootParentModule
loaded[ourModuleName] = ourModule
loaded[relativeRequireName('assert')] = assert
loaded[relativeRequireName('type')] = type
function require(modname)
	assert.parameterTypeIsString('modname', modname)
	
	if modname:isEmpty() then
		error("Please supply a modname to require() that isn't empty")
	end
	
	local moduleNameLocal = modname
	
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
	
	initialiseSearchPaths(moduleNameLocal)
	local failures = {}
	for _, searcher in ipairs(searchers) do
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
				else
					ourResult = {result}
				end
			end
			loaded[moduleNameLocal] = ourResult
			resetModuleGlobals()
			return ourResult
		end
		table.insert(failures, moduleLoaderOrFailedToFindExplanationString)
	end
	
	loaded[moduleNameLocal] = nil
	resetModuleGlobals()
	error(("Could not load module '%s' because of failures:-%s"):format(moduleNameLocal, table.concat(failures, ' or ')))
end

assert.globalTypeIsFunctionOrCall('require')
local function relativeRequire(childModuleName)
	return require(relativeRequireName(childModuleName))
end

local function augment(moduleLeafName)
	return relativeRequire('init.' .. moduleLeafName)	
end

ourModule.type = type
ourModule.assert = assert
ourModule.packageConfiguration = packageConfiguration
ourModule.parentModuleNameFromModuleName = parentModuleNameFromModuleName

-- Used by middleclass
assert.globalTypeIsFunction('setmetatable', 'rawget', 'assert', 'type', 'tostring', 'ipairs', 'pairs')
local class = relativeRequire('middleclass')

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

augment('trace')
augment('requireChild')
augment('requireSibling')
augment('augmentTypeWithMiddleclass')
augment('augmentAssertWithMiddleclass')
augment('augmentAssertWithFieldExists')

return ourModule
