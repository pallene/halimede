--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local GnuTuple = require.sibling('GnuTuple')
local Path = halimede.io.paths.Path
local Recipe = require.sibling('Recipe')
local Platform = require.sibling('Platform')
local PlatformPaths = require.sibling('PlatformPaths')
local tabelize = halimede.table.tabelize


moduleclass('Recipes')

assert.globalTypeIsFunctionOrCall('ipairs', 'pairs')
local function validateAndSortChosenBuildVariantNames(chosenBuildVariantNames)
	assert.parameterTypeIsTable('chosenBuildVariantNames', chosenBuildVariantNames)

	if #chosenBuildVariantNames == 0 then
		exception.throw('Empty buildVariants')
	end
	
	local encountedBuildVariantNames = {}
	for _, chosenBuildVariantName in ipairs(chosenBuildVariantNames) do
		assert.parameterTypeIsString('chosenBuildVariantName', chosenBuildVariantName)
		if encountedBuildVariantNames[chosenBuildVariantName] then
			exception.throw("Duplicate build variant name '%s'", chosenBuildVariantName)
		end
		encountedBuildVariantNames[chosenBuildVariantName] = true
	end
	
	local validatedAndSortedChosenBuildVariantNames = tabelize()
	for chosenBuildVariantName, _ in pairs(encountedBuildVariantNames) do
		validatedAndSortedChosenBuildVariantNames:insert(chosenBuildVariantName)
	end
	validatedAndSortedChosenBuildVariantNames:sort()
	
	return validatedAndSortedChosenBuildVariantNames
end

function module:initialize(recipesPath, recipeEnvironment, buildPlatform, buildPlatformPaths, crossPlatform, crossPlatformPaths)
	assert.parameterTypeIsInstanceOf('recipesPath', recipesPath, Path)
	assert.parameterTypeIsTable('recipeEnvironment', recipeEnvironment)
	assert.parameterTypeIsInstanceOf('buildPlatform', buildPlatform, Platform)
	assert.parameterTypeIsInstanceOf('buildPlatformPaths', buildPlatformPaths, PlatformPaths)
	assert.parameterTypeIsInstanceOf('crossPlatform', crossPlatform, Platform)
	assert.parameterTypeIsInstanceOf('crossPlatformPaths', crossPlatformPaths, PlatformPaths)
	
	self.recipesPath = recipesPath
	self.recipeEnvironment = recipeEnvironment
	
	self.buildPlatform = buildPlatform
	self.buildPlatformPaths = buildPlatformPaths
	self.crossPlatform = crossPlatform
	self.crossPlatformPaths = crossPlatformPaths
	
	self.crossPlatformGnuTuple = crossPlatform.gnuTuple
end

function module:load(recipeName, chosenBuildVariantNames)
	assert.parameterTypeIsString('recipeName', recipeName)
	assert.parameterTypeIsTable('chosenBuildVariantNames', chosenBuildVariantNames)

	local validatedAndSortedChosenBuildVariantNames = validateAndSortChosenBuildVariantNames(chosenBuildVariantNames)
	
	local executor = function(callback)
		return callback(self.buildPlatform, self.buildPlatformPaths, self.crossPlatform, self.crossPlatformPaths)
	end
	
	return Recipe:new(executor, self.recipesPath, self.crossPlatformGnuTuple, self.recipeEnvironment, recipeName, validatedAndSortedChosenBuildVariantNames)
end
