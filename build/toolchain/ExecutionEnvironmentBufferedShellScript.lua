--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local BufferedShellScript = halimede.io.shellScript.BufferedShellScript
moduleclass('ExecutionEnvironmentBufferedShellScript', BufferedShellScript)

local exception = halimede.exception
local tabelize = halimede.table.tabelize
local newline = halimede.packageConfiguration.newline


function module:initialize(shellScriptExecutor, dependencies, buildVariant)
	assert.parameterTypeIsTable('dependencies', dependencies)
	assert.parameterTypeIsTable('buildVariant', buildVariant)
	
	BufferedShellScript.initialize(self, shellScriptExecutor)
	
	self.dependencies = dependencies
	self.buildVariant = buildVariant
	
	local shellLanguage = self.shellLanguage
	self.lowerCasedName = shellLanguage.lowerCasedName
	self.titleCasedName = shellLanguage.titleCasedName
end

assert.globalTypeIsFunction('pcall')
assert.globalTableHasChieldFieldOfTypeFunction('string', 'format')
function module:newAction(namespace, actionName)
	assert.parameterTypeIsString('actionName', actionName)
	
	local actionNamespace
	if namespace == nil then
		actionNamespace = 'halimede.build.shellScriptActions'
	else
		assert.parameterTypeIsString('namespace', namespace)
		actionNamespace = namespace
	end
	
	local errors = tabelize()
	-- Try to see if there's a Posix, Cmd, etc variant
	for _, potentialModuleName in ipairs({
		('%s.%s.%s%sShellScriptAction'):format(actionNamespace, self.lowerCasedName, actionName, self.titleCasedName),
		('%s.%s%sShellScriptAction'):format(actionNamespace, actionName, self.titleCasedName),
		('%s.%sShellScriptAction'):format(actionNamespace, actionName)
	}) do
		local ok, resultOrErrorMessage = pcall(require.functor, potentialModuleName)
		if ok then
			local ShellScriptActionClass = resultOrErrorMessage
			return ShellScriptActionClass:new(self)
		end
		errors:insert(resultOrErrorMessage)
	end
	
	exception.throw("Could not locate an action '%s' in namespace '%s' because of errors:-%s%s", actionName, actionNamespace, newline, errors:concat(newline .. '\tor'))
end
