--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local BufferedShellScript = require('halimede.io.shellScript.BufferedShellScript')
local ToolchainBufferedShellScript = moduleclass('ToolchainBufferedShellScript', BufferedShellScript)

local halimede = require('halimede')
local assert = halimede.assert
local exception = require('halimede.exception')
local Toolchain = requireSibling('Toolchain')


function module:initialize(shellScriptExecutor, toolchain)
	assert.parameterTypeIsInstanceOf(toolchain, Toolchain)
	
	BufferedShellScript.initialize(self, shellScriptExecutor)
	
	self.toolchain = toolchain
	
	local shellLanguage = self.shellLanguage
	self.lowerCasedName = shellLanguage.lowerCasedName
	self.titleCasedName = shellLanguage.titleCasedName
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'format')
function module:newAction(namespace, actionName)
	assert.parameterTypeIsString(actionName)
	
	local actionNamespace
	if namespace == nil then
		actionNamespace = 'halimede.build.shellScriptActions'
	else
		assert.parameterTypeIsString(namespace)
		actionNamespace = namespace
	end
	
	-- Try to see if there's a Posix, Cmd, etc variant
	for _, potentialModuleName in ipairs({
		('%s.%s.%s%sShellScriptAction'):format(actionNamespace, self.lowerCasedName, actionName, self.titleCasedName),
		('%s.%s%sShellScriptAction'):format(actionNamespace, actionName, self.titleCasedName),
		('%s.%sShellScriptAction'):format(actionNamespace, actionName)
	}) do
		local ok, resultOrErrorMessage = pcall(require, potentialShellVariantModuleName)
		if ok then
			local ShellScriptActionClass = resultOrErrorMessage
			return ShellScriptActionClass:new(self, self.toolchain)
		end
	end
	
	exception.throw("Could not locate an action '%s' in namespace '%s'", actionName, actionNamespace)
end
