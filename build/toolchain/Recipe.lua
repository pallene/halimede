--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local executeFromFile = halimede.luacode.executeFromFile
local exception = halimede.exception
local deepMerge = halimede.table.deepMerge
local tabelize = halimede.table.tabelize
local ShellLanguage = halimede.io.shellScript.ShellLanguage
local noRedirection = ShellLanguage.noRedirection
local Recipes = require.sibling('Recipes')
local Path = halimede.io.paths.Path
local Platform = require.sibling('Platform')
local PlatformPaths = require.sibling('PlatformPaths')
local GnuTuple = require.sibling('GnuTuple')
local RecipePaths = require.sibling('RecipePaths')
local ExecutionEnvironmentShellScript = require.sibling('ExecutionEnvironmentShellScript')


moduleclass('Recipe')

local fieldExists = {}

function fieldExists.asTableOrDefaultTo(parent, fieldName)
	local childTable = parent[fieldName]
	if childTable == nil then
		newChildTable = {}
		parent[fieldName] = newChildTable
		return newChildTable
	else
		assert.parameterTypeIsTable('childTable', childTable)
		return childTable
	end
end

function fieldExists.asString(parent, fieldName)
	local fieldValue = parent[fieldName]
	assert.parameterTypeIsString('fieldValue', fieldValue)
	return fieldValue
end

function fieldExists.asFunctionOrCallFieldExistsOrDefaultTo(parent, fieldName, default)
	local fieldValue = parent[fieldName]
	if fieldValue == nil then
		parent[fieldName] = default
		return default
	end
	assert.parameterTypeIsFunctionOrCall('fieldValue', fieldValue)
	return fieldValue
end


function module:initialize(executor, recipesPath, crossPlatformGnuTuple, recipeEnvironment, recipeName, validatedAndSortedChosenBuildVariantNames)
	assert.parameterTypeIsFunctionOrCall('executor', executor)
	assert.parameterTypeIsInstanceOf('recipesPath', recipesPath, Path)
	assert.parameterTypeIsInstanceOf('crossPlatformGnuTuple', crossPlatformGnuTuple, GnuTuple)
	assert.parameterTypeIsTable('recipeEnvironment', recipeEnvironment)
	assert.parameterTypeIsString('recipeName', recipeName)
	assert.parameterTypeIsTable('validatedAndSortedChosenBuildVariantNames', validatedAndSortedChosenBuildVariantNames)

	self.executor = executor
	self.recipesPath = recipesPath
	self.recipeName = recipeName
	self.chosenBuildVariantNames = validatedAndSortedChosenBuildVariantNames
	self.recipeFolderPath = self.recipesPath:appendFolders(recipeName)
	self.recipeFilePath = self.recipeFolderPath:appendFile('recipe', 'lua')
	
	local result = self:_load(recipeEnvironment)
	local aliases, versions = self:_processRecipe(result, crossPlatformGnuTuple)
	self.aliases = aliases
	self.versions = versions
end

function module:_load(recipeEnvironment)
	return executeFromFile('recipe file', self.recipeFilePath, recipeEnvironment)
end

assert.globalTypeIsFunctionOrCall('pairs')
function module:_processRecipe(result, crossPlatformGnuTuple)
	assert.parameterTypeIsTable('result', result)
	
	local aliases = fieldExists.asTableOrDefaultTo(result, 'aliases')
	local versions = fieldExists.asTableOrDefaultTo(result, 'versions')
	local ourVersions = {}
	
	local count = 0
	for packageVersionName, packageVersionSettings in pairs(versions) do
		assert.parameterTypeIsString('versionName', packageVersionName)
		assert.parameterTypeIsTable('packageVersionSettings', packageVersionSettings)
		
		local ourVersion = {}
		
		local dependencies, packageVersion, buildVariant, platformConfigHDefinesFunctions, execute = self:_validate(packageVersionName, packageVersionSettings, crossPlatformGnuTuple)
		ourVersion.dependencies = dependencies
		ourVersion.buildVariant = buildVariant
		ourVersion.platformConfigHDefinesFunctions = platformConfigHDefinesFunctions
		ourVersion.execute = execute
		ourVersion.packageVersion = packageVersionName
		
		if aliases[packageVersionName] then
			exception.throw("There is an alias for an extant version called '%s' in recipe '%s'", packageVersionName, self.recipeName)
		end
		
		ourVersions[packageVersionName] = ourVersion
		
		count = count + 1
	end
	
	if count == 0 then
		exception.throw("There must be at least one version defined in recipe '%s'", self.recipeName)
	end

	if aliases['latest'] == nil and versions['latest'] == nil then
		exception.throw("There must be an alias (or less ideally, version) called 'latest' in the recipe '%s'", self.recipeName)
	end
	
	return aliases, ourVersions
end

assert.globalTypeIsFunctionOrCall('pairs')
function module:_resolveAlias(aliasFrom, alreadyEncounteredAliasFrom)
	alreadyEncounteredAliasFrom = alreadyEncounteredAliasFrom or {}
	
	if self.versions[aliasFrom] then
		return self.versions[aliasFrom]
	end
	
	local recursiveAliasFrom = self.aliases[aliasFrom]
	if type.isString(recursiveAliasFrom) then
		if alreadyEncounteredAliasFrom[alreadyEncounteredAliasFrom] == true then
			exception.throw("Circular aliases in recipe '%s'", self.recipeName)
		end
		alreadyEncounteredAliasFrom[aliasFrom] = true
		return self:_resolveAlias(recursiveAliasFrom, alreadyEncounteredAliasFrom)
	elseif recursiveAliasFrom == nil then
		return nil
	else
		exception.throw("There is an alias which is not a string in aliases for recipe '%s'", self.recipeName)
	end
end

function module:buildVariantsString()
	return self.chosenBuildVariantNames:concat('-')
end

local function configHDefinesPrepare(configHDefines, platform, packageOrganisation, packageName, packageVersion, buildVariantsString)
	
	local version = packageVersion .. '-' .. buildVariantsString
	
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

assert.globalTypeIsFunctionOrCall('ipairs', 'pairs')
local function validateBuildVariantsAndCreateConsolidatedBuildVariant(chosenBuildVariantNames, buildVariants)
			
	for buildVariantName, buildVariantSettings in pairs(buildVariants) do
		assert.parameterTypeIsString('buildVariantName', buildVariantName)
		
		local requires = fieldExists.asTableOrDefaultTo(buildVariantSettings, 'requires')
		for _, requiredBuildVariantName in ipairs(requires) do
			assert.parameterTypeIsString('requiredBuildVariantName', requiredBuildVariantName)
			
			if buildVariants[requiredBuildVariantName] == nil then
				exception.throw("Build variant '%s' requires undefined build variant '%s'", buildVariantName, requiredBuildVariantName)
			end
		end
		
		local conflicts = fieldExists.asTableOrDefaultTo(buildVariantSettings, 'conflicts')
		for _, conflictsBuildVariantName in ipairs(conflicts) do
			assert.parameterTypeIsString('conflictsBuildVariantName', conflictsBuildVariantName)
			
			if buildVariants[conflictsBuildVariantName] == nil then
				exception.throw("Build variant '%s' conflicts undefined build variant '%s'", buildVariantName, conflictsBuildVariantName)
			end
		end
		
		local arguments = fieldExists.asTableOrDefaultTo(buildVariantSettings, 'arguments')
		
		local compilerDriverFlags = fieldExists.asTableOrDefaultTo(buildVariantSettings, 'compilerDriverFlags')
		for _, compilerDriverFlag in ipairs(compilerDriverFlags) do
			assert.parameterTypeIsString('compilerDriverFlag', compilerDriverFlag)
		end
		
		local defines = fieldExists.asTableOrDefaultTo(buildVariantSettings, 'defines')
		-- TODO: Validate
		
		local configHDefines = fieldExists.asTableOrDefaultTo(buildVariantSettings, 'configHDefines')
		-- TODO: Validate
		
		local libs = fieldExists.asTableOrDefaultTo(buildVariantSettings, 'libs')
		for _, lib in ipairs(libs) do
			assert.parameterTypeIsString('lib', lib)
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
		systemIncludePaths = {},
		linkerFlags = {},
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

function module:_validate(packageVersion, version, crossPlatformGnuTuple)
	local dependencies = fieldExists.asTableOrDefaultTo(version, 'dependencies')
		local systemIncludePaths = fieldExists.asTableOrDefaultTo(dependencies, 'systemIncludePaths')
		local linkerFlags = fieldExists.asTableOrDefaultTo(dependencies, 'linkerFlags')
		local libs = fieldExists.asTableOrDefaultTo(dependencies, 'libs')
	local package = fieldExists.asTableOrDefaultTo(version, 'package')
		local packageOrganisation = fieldExists.asString(package, 'organisation')
		local packageName = fieldExists.asString(package, 'name')
	local buildVariants = fieldExists.asTableOrDefaultTo(version, 'buildVariants')
		local buildVariant = validateBuildVariantsAndCreateConsolidatedBuildVariant(self.chosenBuildVariantNames, buildVariants)
	local platformConfigHDefinesFunctions = tabelize()	
	local configH = fieldExists.asTableOrDefaultTo(version, 'configH')
	
		local configHDefinesPrepare = fieldExists.asFunctionOrCallFieldExistsOrDefaultTo(configH, 'prepare', configHDefinesPrepare)
	
		platformConfigHDefinesFunctions:insert(function(configHDefines, platform)
			return configHDefinesPrepare(configHDefines, platform, packageOrganisation, packageName, packageVersion, self:buildVariantsString())
		end)
	
		local configHDefinesDefault = fieldExists.asFunctionOrCallFieldExistsOrDefaultTo(configH, 'default', configHDefinesDefault)
	
		platformConfigHDefinesFunctions:insert(configHDefinesDefault)
	
		local platforms = fieldExists.asTableOrDefaultTo(configH, 'platforms')
		for platformMatch, platformFunction in pairs(platforms) do
			assert.parameterTypeIsString('platformMatch', platformMatch)
			assert.parameterTypeIsFunctionOrCall('platformFunction', platformFunction)
		
			if crossPlatformGnuTuple[platformMatch] == true then
				platformConfigHDefinesFunctions:insert(platformFunction)
			end
		end

	local execute = fieldExists.asFunctionOrCallFieldExistsOrDefaultTo(version, 'execute', executeDefault)

	return dependencies, packageVersion, buildVariant, platformConfigHDefinesFunctions, execute
end

function module:execute(aliasPackageVersion)
	self.executor(function(buildPlatform, buildPlatformPaths, crossPlatform, crossPlatformPaths)
		return self:_execute(aliasPackageVersion, buildPlatform, buildPlatformPaths, crossPlatform, crossPlatformPaths)
	end)
end

function module:_execute(aliasPackageVersion, buildPlatform, buildPlatformPaths, crossPlatform, crossPlatformPaths)
	assert.parameterTypeIsString('aliasPackageVersion', aliasPackageVersion)
	assert.parameterTypeIsInstanceOf('buildPlatform', buildPlatform, Platform)
	assert.parameterTypeIsInstanceOf('buildPlatformPaths', buildPlatformPaths, PlatformPaths)
	assert.parameterTypeIsInstanceOf('crossPlatform', crossPlatform, Platform)
	assert.parameterTypeIsInstanceOf('crossPlatformPaths', crossPlatformPaths, PlatformPaths)
	
	local version = self:_resolveAlias(aliasPackageVersion)
	if version == nil then
		exception.throw("No known version details for aliasPackageVersion '%s' in recipe '%s'", aliasPackageVersion, self.recipeName)
	end
	
	-- Instead of dependencies-hash we could sort and concatenate all the versions of the dependencies, but that rapidly gets longer than a maximum length
	-- We could use short git hashes, eg ABCD-DE99-4567 => our git hash, dep1's git hash, dep2's git hash
	local versionRelativePathElements = {self.recipeName, version.packageVersion, self:buildVariantsString(), 'dependencies-hash'}
	
	local recipeFolderPath = self.recipeFolderPath:appendFolders(version.packageVersion)
		
	local buildRecipePaths = RecipePaths:new(buildPlatform, buildPlatformPaths, versionRelativePathElements)
	local crossRecipePaths = RecipePaths:new(crossPlatform, crossPlatformPaths, versionRelativePathElements)
	
	local buildVariant = version.buildVariant
	
	local displayScriptToStandardError = true
	local shellScript = buildPlatform.shellScriptExecutor:newShellScript(ExecutionEnvironmentShellScript, version.dependencies, buildVariant, displayScriptToStandardError)
	
	self:_populateShellScript(shellScript, recipeFolderPath, buildPlatform, buildRecipePaths, crossPlatform, crossRecipePaths, buildVariant.arguments, version.platformConfigHDefinesFunctions, version.execute)
	
	shellScript:executeScriptExpectingSuccess(noRedirection, noRedirection)
end

local sourceFolderName = 'source'
local buildFolderName = 'build'
local patchFolderName = 'patch'
assert.globalTypeIsFunctionOrCall('ipairs')
function module:_populateShellScript(shellScript, recipeFolderPath, buildPlatform, buildRecipePaths, crossPlatform, crossRecipePaths, arguments, crossPlatformConfigHDefinesFunctions, userFunction)
	local configHDefines = crossPlatform:createConfigHDefines(crossPlatformConfigHDefinesFunctions)

	shellScript:newAction(nil, 'StartScript'):execute(recipeFolderPath, sourceFolderName, buildFolderName, patchFolderName)
	
	local buildEnvironment = {
		
		recipeFolderPath = recipeFolderPath,
		
		sourceFolderName = sourceFolderName,
		
		buildFolderName = buildFolderName,
		
		patchFolderName = patchFolderName,
		
		buildPlatform = buildPlatform,
		
		buildRecipePaths = buildRecipePaths,
		
		crossPlatform = crossPlatform,
		
		crossRecipePaths = crossRecipePaths,
		
		action = function(namespace, name, ...)
			shellScript:newAction(namespace, name):execute(...)
		end,
		
		arguments = arguments,
		
		configHDefines = configHDefines
	}
	
	local result = userFunction(buildEnvironment)
	
	shellScript:newAction(nil, 'EndScript'):execute()
end
