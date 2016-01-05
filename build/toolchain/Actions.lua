--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local ShellScript = halimede.io.shellScript.ShellScript
local ShellPath = halimede.io.shellScript.ShellPath
local Builder = require.sibling.Builder


local Actions = halimede.moduleclass('Actions')

local function execute(self, actionName, ...)
	assert.parameterTypeIsInstanceOf('self', self, Actions)
	assert.parameterTypeIsString('actionName', actionName)

	local actionClassOrCreatorFunction = require(self.namespace .. '.' .. actionName .. ('%sShellScriptAction'):format(self.shellScript.shellLanguage.titleCasedName))
	return actionClassOrCreatorFunction(self.dependencies, self.buildVariant):execute(self.shellScript, self.builder, ...)
end

Actions.setInstanceMissingIndex(function(instance, key)
	return function(self, ...)
		-- Not perfect; fails if any method takes itself as second argument
		if self == instance then
			return execute(instance, key, ...)
		else
			return execute(instance, key, self, ...)
		end
	end
end)

local function appendCompositeActionRecreateFolderPath(actions)
	actions.RecreateFolderPath = function(self, shellPath)
		assert.parameterTypeIsInstanceOf('self', self, Actions)
		assert.parameterTypeIsInstanceOf('shellPath', shellPath, ShellPath)
		shellPath:assertIsFolderPath('shellPath')

		local folderName = shellPath:finalPathElementNameAsString()
		actions.Comment("Recreate empty '" .. folderName .. "' folder")
		actions.RemoveRecursivelyWithForce(shellPath)
		actions.MakeDirectoryRecursively(shellPath, '0755')
	end
end
module.static.appendCompositeActionRecreateFolderPath = appendCompositeActionRecreateFolderPath

function module:initialize(shellScript, builder, dependencies, buildVariant, namespace)
	assert.parameterTypeIsInstanceOf('shellScript', shellScript, ShellScript)
	assert.parameterTypeIsInstanceOf('builder', builder, Builder)
	assert.parameterTypeIsTable('dependencies', dependencies)
	assert.parameterTypeIsTable('buildVariant', buildVariant)
	assert.parameterTypeIsString('namespace', namespace)

	self.shellScript = shellScript
	self.builder = builder
	self.dependencies = dependencies
	self.buildVariant = buildVariant
	self.namespace = namespace
end

function module:__call(childNamespaceName)
	assert.parameterTypeIsString('childNamespaceName', childNamespaceName)

	return Actions:new(self.shellScript, self.builder, self.dependencies, self.buildVariant, self.namespace .. '.' .. childNamespaceName)
end
