--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


moduleclass('Recipe')

local halimede = require('halimede')
local assert = halimede.assert
local class = require('halimede.middleclass')
local executeFromFile = require('halimede.luacode.executeFromFile').executeFromFile
local exception = require('halimede.exception')
local deepMerge = require('halimede.table.deepMerge').deepMerge
local tabelize = require('halimede.table.tabelize').tabelize
local CStandard = require('halimede.build.toolchain.CStandard')
local LegacyCandCPlusPlusStringLiteralEncoding = require('halimede.build.toolchain.LegacyCandCPlusPlusStringLiteralEncoding')
local CommandLineDefines = require('halimede.build.defines.CommandLineDefines')
local BuildEnvironment = require('halimede.build.toolchain.BuildEnvironment')
local _FILE_OFFSET_BITS = require('halimede.build.defines._FILE_OFFSET_BITS')
local CRAY_STACKSEG_END = require('halimede.build.defines.CRAY_STACKSEG_END')
local RETSIGTYPE = require('halimede.build.defines.RETSIGTYPE')
local ST_MTIM_NSEC = require('halimede.build.defines.ST_MTIM_NSEC')
local STACK_DIRECTION = require('halimede.build.defines.STACK_DIRECTION')
local AbstractPath = require('halimede.io.paths.AbstractPath')





assert.globalTypeIsFunction('ipairs', 'pairs')
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
	
	local result = tabelize()
	for chosenBuildVariantName, _ in pairs(encountedBuildVariantNames) do
		result:insert(chosenBuildVariantName)
	end
	result:sort()
	
	return result
end

function module:initialize(recipesPath, recipeName, chosenBuildVariantNames)
	assert.parameterTypeIsInstanceOf(recipesPath, AbstractPath)
	assert.parameterTypeIsString(recipeName)
	
	self.recipeFolderPath = recipesPath:appendSubFolders(recipeName)
	self.recipeFilePath = recipeFolderPath:appendSubFolders('recipe.lua')
	self.recipeSourcePath = recipeFolderPath:appendSubFolders('source')
	self.recipeWorkingDirectoryPath = recipeFolderPath:appendSubFolders('.build')
	self.chosenBuildVariantNames = validateAndSortChosenBuildVariantNames(chosenBuildVariantNames)
end

local function configHDefinesNew(configH, packageOrganisation, packageName, packageVersion, chosenBuildVariantNames)
	
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

local function executeDefault(buildEnvironmentLight)
end

assert.globalTypeIsFunction('ipairs', 'pairs')
local function validateBuildVariantsAndCreateConsolidatedBuildVariant(chosenBuildVariantNames, buildVariants)
			
	for buildVariantName, buildVariantSettings in pairs(buildVariants)
		assert.parameterTypeIsString(buildVariantName)
		
		local requires = assert.fieldExistsAsTableOrDefaultTo(buildVariantSettings, 'requires')
		for _, requiredBuildVariantName in ipairs(requires) do
			assert.parameterTypeIsString(requiredBuildVariantName)
			if buildVariants[name] == nil then
				exception.throw("Build variant '%s' requires undefined build variant '%s'", buildVariantName, requiredBuildVariantName)
			end
		end
		
		local conflicts = assert.fieldExistsAsTableOrDefaultTo(buildVariantSettings, 'conflicts')
		for _, conflictsBuildVariantName in ipairs(conflicts) do
			assert.parameterTypeIsString(conflictsBuildVariantName)
			if buildVariants[name] == nil then
				exception.throw("Build variant '%s' conflicts undefined build variant '%s'", buildVariantName, conflictsBuildVariantName)
			end
		end
		
		local arguments = assert.fieldExistsAsTableOrDefaultTo(buildVariantSettings, 'arguments')
		
		local compilerDriverFlags = assert.fieldExistsAsTableOrDefaultTo(buildVariantSettings, 'compilerDriverFlags')
		for _, compilerDriverFlag in ipairs(compilerDriverFlags) do
			assert.parameterTypeIsString(compilerDriverFlag)
		end
		
		local defines = assert.fieldExistsAsTableOrDefaultTo(buildVariantSettings, 'defines')
		-- TODO: Validate
		
		local configHDefines = assert.fieldExistsAsTableOrDefaultTo(buildVariantSettings, 'configHDefines')
		-- TODO: Validate
		
		local libs = assert.fieldExistsAsTableOrDefaultTo(buildVariantSettings, 'libs')
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

function module:_load()
	local environment = {
		CStandard = CStandard,
		LegacyCandCPlusPlusStringLiteralEncoding = LegacyCandCPlusPlusStringLiteralEncoding,
		CommandLineDefines = CommandLineDefines,
		_FILE_OFFSET_BITS = _FILE_OFFSET_BITS,
		CRAY_STACKSEG_END = CRAY_STACKSEG_END,
		RETSIGTYPE = RETSIGTYPE,
		ST_MTIM_NSEC = ST_MTIM_NSEC,
		STACK_DIRECTION = STACK_DIRECTION
	}
	
	return executeFromFile('recipe file', self.recipeFilePath.path, environment)
end

function module:_validate(result)
	local dependencies = assert.fieldExistsAsTableOrDefaultTo(result, 'dependencies')
	local package = assert.fieldExistsAsTableOrDefaultTo(result, 'package')
		local packageOrganisation = assert.fieldExistsAsString(package, 'organisation')
		local packageName = assert.fieldExistsAsString(package, 'name')
		local packageVersion = assert.fieldExistsAsString(package, 'version')  -- TODO: should not really be embedded in the recipe
	local buildVariants = assert.fieldExistsAsTableOrDefaultTo(result, 'buildVariants')
		local consolidatedBuildVariant = validateBuildVariantsAndCreateConsolidatedBuildVariant(chosenBuildVariantNames, buildVariants)
	
	local platformConfigHDefinesFunctions = tabelize()	
	local configH = assert.fieldExistsAsTableOrDefaultTo(result, 'configH')
		
		local configHDefinesNew = assert.fieldExistsAsFunctionOrCallFieldExistsOrDefaultTo(configH, 'configHDefinesNew', configHDefinesNew)
		
		platformConfigHDefinesFunctions:insert(function(configHDefines, platform)
			return configHDefinesNew(configHDefines, packageOrganisation, packageName, packageVersion, chosenBuildVariantNames)
		end)
		
		local configHDefinesDefault = assert.fieldExistsAsFunctionOrCallFieldExistsOrDefaultTo(configH, 'configHDefinesDefault', configHDefinesDefault)
		
		platformConfigHDefinesFunctions:insert(configHDefinesDefault)
		
		local platforms = assert.fieldExistsAsTableOrDefaultTo(configH, 'platforms')
		for platformMatch, platformFunction in pairs(platforms) do
			assert.parameterTypeIsString(platformMatch)
			assert.parameterTypeIsFunctionOrCall(platformFunction)
			
			if crossPlatform.gnuTuple[platformMatch] == true then
				platformConfigHDefinesFunctions:insert(platformFunction)
			end
		end
	
	local execute = ensureFunctionOrCallFieldExistsOrDefault(result, 'execute', executeDefault)
	
	return dependencies, consolidatedBuildVariant, platformConfigHDefinesFunctions, execute
end

assert.globalTypeIsFunction('ipairs', 'pairs')
function module:execute(buildPlatform, crossPlatform, buildSysrootPath, crossSysrootPath)
	
	local result = self:_load()
	local dependencies, consolidatedBuildVariant, platformConfigHDefinesFunctions, execute = self:_validate(result)
	
	local buildToolchain = Toolchain(buildPlatform, buildSysrootPath)
	local crossToolchain = Toolchain(crossPlatform, crossSysrootPath)
	
	local buildEnvironment = BuildEnvironment:new(buildToolchain, crossToolchain)
	buildEnvironment:use(true, dependencies, consolidatedBuildVariant, self.recipeSourcePath, configHDefinesNewWrapperFunction, platformConfigHDefinesFunctions, execute)
end
