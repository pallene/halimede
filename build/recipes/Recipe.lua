--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


moduleclass('Recipe')

local halimede = require('halimede')
local assert = halimede.assert
local executeFromFile = require('halimede.luacode.executeFromFile').executeFromFile
local exception = require('halimede.exception')
local deepMerge = require('halimede.table.deepMerge').deepMerge
local tabelize = require('halimede.table.tabelize').tabelize
local noRedirection = require('halimede.io.execute').noRedirection

local Path = require('halimede.io.paths.Path')
local ToolchainPaths = require('halimede.build.toolchain.ToolchainPaths')
local ExecutionEnvironment = require('halimede.build.toolchain.ExecutionEnvironment')


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
	assert.parameterTypeIsInstanceOf(recipesPath, Path)
	assert.parameterTypeIsString(recipeName)
	
	recipesPath:assertIsFolderPath('recipesPath')
	
	self.recipeFolderPath = recipesPath:appendSubFolders(recipeName)
	self.recipeFilePath = recipeFolderPath:appendSubFolders('recipe.lua')
	self.recipeSourcePath = recipeFolderPath:appendSubFolders('source')
	self.recipeWorkingDirectoryPath = recipeFolderPath:appendSubFolders('.build')
	self.chosenBuildVariantNames = validateAndSortChosenBuildVariantNames(chosenBuildVariantNames)
end

function module:versionStringIncludingBuildVariants(packageVersion)
	return packageVersion .. '-' .. self.chosenBuildVariantNames:concat('-')
end

local function configHDefinesNew(configH, packageOrganisation, packageName, packageVersion, chosenBuildVariantNames)
	
	local version = self:versionStringIncludingBuildVariants(packageVersion)
	
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
	
	for _, chosenBuildVariantName in ipairs(self.chosenBuildVariantNames) do
		local buildVariantSettings = buildVariants[chosenBuildVariantName]
		if buildVariantSettings == nil then
			exception.throw("Unknown chosen build variant '%s'", chosenBuildVariantName)
		end
		
		for _, requiredBuildVariantName in ipairs(buildVariantSettings.requires) do
			if self.chosenBuildVariantNames[requiredBuildVariantName] ~= nil then
				exception.throw("Chosen build variant '%s' requires chosen build variant '%s'", chosenBuildVariantName, requiredBuildVariantName)
			end
		end
		
		for _, conflictsBuildVariantName in ipairs(buildVariantSettings.conflicts) do
			if self.chosenBuildVariantNames[conflictsBuildVariantName] ~= nil then
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

function module:_load(executionEnvironment)
	return executeFromFile('recipe file', self.recipeFilePath:formatPath(true), executionEnvironment.recipeEnvironment)
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
			return configHDefinesNew(configHDefines, packageOrganisation, packageName, packageVersion, self.chosenBuildVariantNames)
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
	
	return dependencies, packageVersion, consolidatedBuildVariant, platformConfigHDefinesFunctions, execute
end

-- local executionEnvironment = ExecutionEnvironment:new(buildPlatform, buildToolchainPaths, crossPlatform)
assert.globalTypeIsFunction('ipairs', 'pairs')
function module:execute(executionEnvironment)
	
	local result = self:_load()
	local dependencies, packageVersion, consolidatedBuildVariant, platformConfigHDefinesFunctions, execute = self:_validate(result)
	
	-- We also ought to capture hash of the recipe file path and of the toolchain / build code
	-- there are two possibilities: destinationPath/opt/recipe/version+buildvariants+hash-of-dependencyversions OR destinationPath/
	-- sysrootPath
	error("There is no executionEnvironment.sysrootPath")
	local crossToolchainPaths = ToolchainPaths:new(executionEnvironment.sysrootPath, executionEnvironment.sysrootPath:appendSubFolders('opt', self.recipeName, self:versionStringIncludingBuildVariants(packageVersion), 'dependencies-hash'))
	local shellScript = executionEnvironment:use(crossToolchainPaths, self.recipeSourcePath, dependencies, consolidatedBuildVariant, platformConfigHDefinesFunctions, execute)
	shellScript:executeScriptExpectingSuccess(noRedirection, noRedirection)
end
