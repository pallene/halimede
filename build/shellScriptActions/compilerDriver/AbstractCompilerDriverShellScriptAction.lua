--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction


moduleclass('AbstractCompilerDriverShellScriptAction', AbstractShellScriptAction)

function module:initialize(dependencies, buildVariant, unsetEnvironmentVariableActionClass, exportEnvironmentVariableActionClass)
	assert.parameterTypeIsTable('dependencies', dependencies)
	assert.parameterTypeIsTable('buildVariant', buildVariant)
	assert.parameterTypeIsFunctionOrCall('unsetEnvironmentVariableActionClass', unsetEnvironmentVariableActionClass)
	assert.parameterTypeIsFunctionOrCall('exportEnvironmentVariableActionClass', exportEnvironmentVariableActionClass)
	
	AbstractShellScriptAction.initialize(self)
	
	self.dependencies = dependencies
	self.buildVariant = buildVariant
	self.unsetEnvironmentVariableAction = unsetEnvironmentVariableActionClass:new()
	self.exportEnvironmentVariableAction = exportEnvironmentVariableActionClass:new()
end

function module:_newCCompilerDriverArguments(crossRecipePaths, compilerDriverFlags, shellLanguage)
	return crossRecipePaths.platform.cCompilerDriver:newArguments(compilerDriverFlags, crossRecipePaths.platformPaths:sysroot(), true, shellLanguage)
end

function module:_unsetEnvironmentVariables(shellScript, builder, compilerDriverArguments)
	local compilerDriver = compilerDriverArguments.compilerDriver
	
	compilerDriver:unsetEnvironmentVariables(function(environmentVariableName)
		self.unsetEnvironmentVariableAction:execute(shellScript, builder, environmentVariableName)
	end)
end

function module:_exportEnvironmentVariables(shellScript, builder, compilerDriverArguments, extras)
	local compilerDriver = compilerDriverArguments.compilerDriver
	
	compilerDriver:exportEnvironmentVariables(function(environmentVariableName, environmentVariableValue)
		self.exportEnvironmentVariableAction:execute(shellScript, builder, environmentVariableName, environmentVariableValue)
	end, extras)
end
