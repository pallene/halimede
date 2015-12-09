--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = halimede.exception
local tabelize = halimede.table.tabelize
local newline = halimede.packageConfiguration.newline
local ShellScript = halimede.io.shellScript.ShellScript


moduleclass('ExecutionEnvironmentShellScript', ShellScript)

function module:initialize(shellScriptExecutor, dependencies, buildVariant)
	assert.parameterTypeIsTable('dependencies', dependencies)
	assert.parameterTypeIsTable('buildVariant', buildVariant)
	
	ShellScript.initialize(self, shellScriptExecutor)
	
	self.dependencies = dependencies
	self.buildVariant = buildVariant
	
	local shellLanguage = self.shellLanguage
	self.lowerCasedName = shellLanguage.lowerCasedName
	self.titleCasedName = shellLanguage.titleCasedName
end

assert.globalTypeIsFunctionOrCall('require')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'format')
function module:newAction(namespace, actionName)
	assert.parameterTypeIsString('actionName', actionName)
	
	local actionNamespace
	if namespace == nil then
		actionNamespace = 'halimede.build.shellScriptActions'
	else
		assert.parameterTypeIsString('namespace', namespace)
		actionNamespace = namespace
	end
	
	local actionClass = require(actionNamespace .. '.' .. actionName .. ('%sShellScriptAction'):format(self.titleCasedName))
	return actionClass:new(self.dependencies, self.buildVariant)
end
