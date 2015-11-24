--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


moduleclass('ExecutionEnvironment')

local halimede = require('halimede')
local tabelize = halimede.table.tabelize
local Platform = requireSibling('Platform')
local Toolchain = requireSibling('Toolchain')
local ToolchainPaths = requireSibling('ToolchainPaths')
local Path = halimede.io.paths.Path')
local ExecutionEnvironmentBufferedShellScript = halimede.build.toolchain.ExecutionEnvironmentBufferedShellScript')


function module:initialize(recipesPath, buildPlatform, buildToolchainPaths, crossPlatform, destinationPath, recipeEnvironment)
	assert.parameterTypeIsInstanceOf('recipesPath', recipesPath, Path)
	assert.parameterTypeIsInstanceOf('buildPlatform', buildPlatform, Platform)
	assert.parameterTypeIsInstanceOf('buildToolchainPaths', buildToolchainPaths, ToolchainPaths)
	assert.parameterTypeIsInstanceOf('crossPlatform', crossPlatform, Platform)
	assert.parameterTypeIsInstanceOf('destinationPath', destinationPath, Path)
	assert.parameterTypeIsTable('recipeEnvironment', recipeEnvironment)
	
	recipesPath:assertIsFolderPath('recipesPath')
	
	self.recipesPath = recipesPath
	self.buildPlatform = buildPlatform
	self.buildToolchainPaths = buildToolchainPaths
	self.crossPlatform = crossPlatform
	self.destinationPath = destinationPath
	self.recipeEnvironment = recipeEnvironment
	
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
	
	local buildEnvironment = {
		
		buildToolchain = Toolchain:new(self.buildPlatform, self.buildToolchainPaths),
		
		crossToolchain = Toolchain:new(self.crossPlatform, crossToolchainPaths),
		
		sourcePath = sourcePath,
		
		action = function(namespace, name, ...)
			shellScript:newAction(namespace, name):execute(...)
		end,
		
		arguments = buildVariant.arguments,
		
		configHDefines = self.crossPlatform:createConfigHDefines(platformConfigHDefinesFunctions)
	}
	
	local result = userFunction(buildEnvironment)
	
	shellScript:newAction(nil, 'EndScript'):execute()
	
	return shellScript
end

function module:_newShellScript(toolchain, dependencies, consolidatedBuildVariant)
	local shellScriptExecutor = toolchain.platform.shellScriptExecutor
	return shellScriptExecutor:newShellScript(ExecutionEnvironmentBufferedShellScript, dependencies, consolidatedBuildVariant)
end
