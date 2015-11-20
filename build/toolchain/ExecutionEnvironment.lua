--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


moduleclass('ExecutionEnvironment')

local halimede = require('halimede')
local tabelize = require('halimede.table.tabelize').tabelize
local Platform = requireSibling('Platform')
local Toolchain = requireSibling('Toolchain')
local ToolchainPaths = requireSibling('ToolchainPaths')
local Path = require('halimede.io.paths.Path')
local defaultRecipeEnvironment = requireSibling('recipeEnvironment')
local ExecutionEnvironmentBufferedShellScript = require('halimede.build.toolchain.ExecutionEnvironmentBufferedShellScript')


assert.globalTypeIsFunction('select', 'ipairs')
local function addFileExtensionToFileNames(pathStyle, extensionWithoutLeadingPeriod, ...)
	local asTable
	if select('#', ...) == 1 then
		local first = select(1, ...)
		if type.isTable(first) then
			asTable = select(1, ...)
		else
			asTable = {...}
		end
	else
		asTable = {...}
	end
	
	local result = tabelize()
	for _, basefilename in ipairs(asTable) do
		result:insert(pathStyle:appendFileExtension(basefilename, extensionWithoutLeadingPeriod))
	end
	return result
end

function module:initialize(recipesPath, buildPlatform, buildToolchainPaths, crossPlatform, destinationPath, recipeEnvironment)
	assert.parameterTypeIsInstanceOf('recipesPath', recipesPath, Path)
	assert.parameterTypeIsInstanceOf('buildPlatform', buildPlatform, Platform)
	assert.parameterTypeIsInstanceOf('buildToolchainPaths', buildToolchainPaths, ToolchainPaths)
	assert.parameterTypeIsInstanceOf('crossPlatform', crossPlatform, Platform)
	assert.parameterTypeIsInstanceOf('destinationPath', destinationPath, Path)
	assert.parameterTypeIsTableOrNil('recipeEnvironment', recipeEnvironment)
	
	recipesPath:assertIsFolderPath('recipesPath')
	
	self.recipesPath = recipesPath
	self.buildPlatform = buildPlatform
	self.buildToolchainPaths = buildToolchainPaths
	self.crossPlatform = crossPlatform
	self.destinationPath = destinationPath
	
	if recipeEnvironment == nil then
		self.recipeEnvironment = defaultRecipeEnvironment
	else
		assert.parameterTypeIsTable('recipeEnvironment', recipeEnvironment)
		self.recipeEnvironment = recipeEnvironment
	end
	
	if buildPlatform == crossPlatform then
		isCrossCompiling = false
	else
		isCrossCompiling = true
	end
	self.isCrossCompiling = isCrossCompiling
end

assert.globalTypeIsFunction('ipairs')
function module:createShellScript(crossToolchainPaths, sourcePath, dependencies, consolidatedBuildVariant, platformConfigHDefinesFunctions, userFunction)
	assert.parameterTypeIsInstanceOf('crossToolchainPaths', crossToolchainPaths, ToolchainPaths)
	assert.parameterTypeIsInstanceOf('sourcePath', sourcePath, Path)
	assert.parameterTypeIsTable('dependencies', dependencies)
	assert.parameterTypeIsTable('consolidatedBuildVariant', consolidatedBuildVariant)
	assert.parameterTypeIsTable('platformConfigHDefinesFunctions', platformConfigHDefinesFunctions)
	assert.parameterTypeIsFunctionOrCall('userFunction', userFunction)
	
	sourcePath:assertIsFolderPath('sourcePath')
	sourcePath:assertIsEffectivelyAbsolute('sourcePath')
	
	local shellScript = self:_newShellScript(self.buildToolchain, dependencies, consolidatedBuildVariant)
	shellScript:newAction(nil, 'StartScript'):execute(sourcePath)
	
	local buildPathStyle = self.buildPlatform.shellScriptExecutor.shellLanguage.pathStyle
	local function addFileExtensionToFileNamesWithPathStyle(extensionWithoutLeadingPeriod, ...)
		return addFileExtensionToFileNames(buildPathStyle, extensionWithoutLeadingPeriod, ...)
	end
	
	local buildEnvironment = {
		
		buildToolchain = Toolchain:new(self.buildPlatform, self.buildToolchainPaths),
		
		crossToolchain = Toolchain:new(self.crossPlatform, crossToolchainPaths),
		
		sourcePath = sourcePath,
				
		addFileExtensionToFileNames = addFileExtensionToFileNamesWithPathStyle,
		
		toCFiles = function(...)
			return addFileExtensionToFileNamesWithPathStyle('c', ...)
		end,
		
		toCxxFiles = function(...)
			return addFileExtensionToFileNamesWithPathStyle('cxx', ...)
		end,
		
		action = function(name, namespace, ...)
			shellScript:newAction(namespace, name):execute(...)
		end,
		
		arguments = buildVariant.arguments,
		
		configHDefines = self.crossPlatform:createConfigHDefines(platformConfigHDefinesFunctions)
	}
	
	userFunction(buildEnvironment)
	
	shellScript:newAction(nil, 'EndScript'):execute()
end

function module:_newShellScript(toolchain, dependencies, consolidatedBuildVariant)
	local shellScriptExecutor = toolchain.platform.shellScriptExecutor
	return shellScriptExecutor:newShellScript(ExecutionEnvironmentBufferedShellScript, dependencies, consolidatedBuildVariant)
end
