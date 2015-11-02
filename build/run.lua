--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('halimede.middleclass')
local executeFromFile = require('halimede.luacode.executeFromFile')
local exception = require('halimede.exception')
local deepMerge = require('halimede.table.deepMerge').deepMerge

local CStandard = require('halimede.build.recipes.CStandard')
local Defines = require('halimede.build.defines.Defines')
local _FILE_OFFSET_BITS = require('halimede.build.defines._FILE_OFFSET_BITS')
local CRAY_STACKSEG_END = require('halimede.build.defines.CRAY_STACKSEG_END')
local RETSIGTYPE = require('halimede.build.defines.RETSIGTYPE')
local ST_MTIM_NSEC = require('halimede.build.defines.ST_MTIM_NSEC')
local STACK_DIRECTION = require('halimede.build.defines.STACK_DIRECTION')

local function ensureTableExistsOrDefault(parent, fieldName)
	local childTable = parent[fieldName]
	if childTable == nil then
		newChildTable = {}
		parent['name'] = newChildTable
		return newChildTable
	else
		assert.parameterTypeIsTable(childTable)
	end
end

local function ensureStringFieldExists(parent, fieldName)
	local fieldValue = parent[fieldName]
	assert.parameterTypeIsString(fieldValue)
	return fieldValue
end

local function ensureFunctionOrCallFieldExistsOrDefault(parent, fieldName, default)
	local fieldValue = parent[fieldName]
	if fieldValue == nil then
		parent[fieldName] = default
		return default
	end
	assert.parameterTypeIsFunctionOrCall(fieldValue)
	return fieldValue
end

local function configHDefinesNews(configH, packageOrganisation, packageName, packageVersion, chosenBuildVariantNames)
	
	local version = packageVersion .. '-' .. table.concat(chosenBuildVariantNames, '-')
	
	configHDefines:PACKAGE(packageName)
	--configHDefines:PACKAGE_BUGREPORT('bug-' .. packageName .. '@gnu.org')
	configHDefines:PACKAGE_NAME(packageOrganisation .. ' ' .. packageName)
	configHDefines:PACKAGE_STRING(packageOrganisation .. ' ' .. packageName .. ' ' .. version)
	configHDefines:PACKAGE_TARNAME(packageName)
	--configHDefines:PACKAGE_URL('http://www.gnu.org/software/' .. packageName .. '/')
	configHDefines:PACKAGE_VERSION(version)
	configHDefines:VERSION(version)
end

local function configHDefinesDefault(configHDefines, platform)
end

local function validateAndSortChosenBuildVariantNames(chosenBuildVariantNames)
	assert.parameterTypeIsTable(chosenBuildVariantNames)

	if #chosenBuildVariantNames == 0 then
		exception.throw('Empty buildVariants')
	end
	
	local encountedBuildVariantNames = {}
	for _, chosenBuildVariantName in ipairs(chosenBuildVariantNames) do
		assert.parameterTypeIsString(chosenBuildVariantName)
		if encountedBuildVariantNames[chosenBuildVariantName] then
			exception.throw("Duplicate build variant name '%s'", chosenBuildVariantName)
		end
		encountedBuildVariantNames[chosenBuildVariantName] = true
	end
	
	table.sort(chosenBuildVariantNames)
	
	return chosenBuildVariantNames
end

assert.globalTypeIsFunction('ipairs', 'pairs')
local function validateBuildVariantsAndCreateConsolidatedBuildVariant(chosenBuildVariantNames, buildVariants)
			
	for buildVariantName, buildVariantSettings in pairs(buildVariants)
		assert.parameterTypeIsString(buildVariantName)
		
		local requires = ensureTableExistsOrDefault(buildVariantSettings, 'requires')
		for _, requiredBuildVariantName in ipairs(requires) do
			assert.parameterTypeIsString(requiredBuildVariantName)
			if buildVariants[name] == nil then
				exception.throw("Build variant '%s' requires undefined build variant '%s'", buildVariantName, requiredBuildVariantName)
			end
		end
		
		local conflicts = ensureTableExistsOrDefault(buildVariantSettings, 'conflicts')
		for _, conflictsBuildVariantName in ipairs(conflicts) do
			assert.parameterTypeIsString(conflictsBuildVariantName)
			if buildVariants[name] == nil then
				exception.throw("Build variant '%s' conflicts undefined build variant '%s'", buildVariantName, conflictsBuildVariantName)
			end
		end
		
		local arguments = ensureTableExistsOrDefault(buildVariantSettings, 'arguments')
		
		local compilerDriverFlags = ensureTableExistsOrDefault(buildVariantSettings, 'compilerDriverFlags')
		for _, compilerDriverFlag in ipairs(compilerDriverFlags) do
			assert.parameterTypeIsString(compilerDriverFlag)
		end
		
		local defines = ensureTableExistsOrDefault(buildVariantSettings, 'defines')
		-- TODO: Validate
		
		local configHDefines = ensureTableExistsOrDefault(buildVariantSettings, 'configHDefines')
		-- TODO: Validate
		
		local libs = ensureTableExistsOrDefault(buildVariantSettings, 'libs')
		for _, lib in ipairs(libs) do
			assert.parameterTypeIsString(lib)
		end
	end
	
	if buildVariants['default'] == nil then
		exception.throw("No build variant 'default' defined in recipe")
	end
	
	local consolidatedBuildVariants = {
		arguments = {},
		compilerDriverFlags = {},
		defines = {},
		configHDefines = {},
		libs = {}
	}
	
	for _, chosenBuildVariantName in ipairs(chosenBuildVariantNames) do
		local buildVariantSettings = buildVariants[chosenBuildVariantName]
		if buildVariantSettings == nil then
			exception.throw("Unknown chosen build variant '%s'", chosenBuildVariantName)
		end
		
		for _, requiredBuildVariantName in ipairs(buildVariantSettings.requires) do
			if chosenBuildVariantNames[requiredBuildVariantName] ~= nil then
				exception.throw("Chosen build variant '%s' requires chosen build variant '%s'", chosenBuildVariantName, requiredBuildVariantName)
			end
		end
		
		for _, conflictsBuildVariantName in ipairs(buildVariantSettings.conflicts) do
			if chosenBuildVariantNames[conflictsBuildVariantName] ~= nil then
				exception.throw("Chosen build variant '%s' conflicts with chosen build variant '%s'", chosenBuildVariantName, conflictsBuildVariantName)
			end
		end
		
		deepMerge(buildVariantSettings.arguments, consolidatedBuildVariants.arguments)
		deepMerge(buildVariantSettings.compilerDriverFlags, consolidatedBuildVariants.compilerDriverFlags)
		deepMerge(buildVariantSettings.defines, consolidatedBuildVariants.defines)
		deepMerge(buildVariantSettings.configHDefines, consolidatedBuildVariants.configHDefines)
		deepMerge(buildVariantSettings.libs, consolidatedBuildVariants.libs)
	end
	
	return consolidatedBuildVariants
end

assert.globalTypeIsFunction('ipairs', 'pairs')
function module.loadRecipe(recipeFilePath, chosenBuildVariantNames)
	assert.parameterTypeIsString(recipeFilePath)
	
	local chosenBuildVariantNames = validateAndSortChosenBuildVariantNames(chosenBuildVariantNames)
	
	local environment = {
		CStandard = CStandard,
		Defines = Defines,
		_FILE_OFFSET_BITS = _FILE_OFFSET_BITS,
		CRAY_STACKSEG_END = CRAY_STACKSEG_END,
		RETSIGTYPE = RETSIGTYPE,
		ST_MTIM_NSEC = ST_MTIM_NSEC,
		STACK_DIRECTION = STACK_DIRECTION,
		
		sysrootPath = '/opt',
		destinationPath = '/opt/package/version'  -- Where version is, say, 2.0.4-lua-5.2 and package is luarocks
	}
	
	local result = executeFromFile('rockspec file', recipeFilePath, environment)
	
	local dependencies = ensureTableExistsOrDefault(result, 'dependencies')
	local package = ensureTableExistsOrDefault(result, 'package')
		local packageOrganisation = ensureStringFieldExists(package, 'organisation')
		local packageName = ensureStringFieldExists(package, 'name')
		local packageVersion = ensureStringFieldExists(package, 'version')  -- TODO: should not really be embedded in the recipe
	local buildVariants = ensureTableExistsOrDefault(result, 'buildVariants')
		local consolidatedBuildVariant = validateBuildVariantsAndCreateConsolidatedBuildVariant(chosenBuildVariantNames, buildVariants)
		
	local configH = ensureTableExistsOrDefault(result, 'configH')
		local configHDefines = crossPlatform:newConfigHDefines()
		
		local configHDefinesNew = ensureFunctionOrCallFieldExistsOrDefault(configH, 'configHDefinesNew', configHDefinesNew)
		configHDefinesNew(configHDefines, packageOrganisation, packageName, packageVersion, chosenBuildVariantNames)
		
		local configHDefinesDefault = ensureFunctionOrCallFieldExistsOrDefault(configH, 'configHDefinesDefault', configHDefinesDefault)
		configHDefinesDefault(configHDefines, crossPlatorm)
		
		local platforms = ensureTableExistsOrDefault(configH, 'platforms')
		for platformMatch, platformFunction in pairs(platforms) do
			assert.parameterTypeIsString(platformMatch)
			assert.parameterTypeIsFunctionOrCall(platformFunction)
			
			if crossPlatform.gnuTuple[platformMatch] == true then
				platformFunction(configHDefines, crossPlatorm)
			end
		end
	
	local compilationUnits = ensureTableExistsOrDefault(result, 'compilationUnits')
	
	XXXXX: How? (choose windows or POSIX)
	local compileUnitActions = platform:newCompileUnitActions()
	
	XXXX: crossPlatform - from where ?
	
end
