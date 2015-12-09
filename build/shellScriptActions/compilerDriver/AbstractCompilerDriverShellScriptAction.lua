--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction


moduleclass('AbstractCompilerDriverShellScriptAction', AbstractShellScriptAction)

function module:initialize(dependencies, buildVariant, unsetEnvironmentVariableActionCreator, exportEnvironmentVariableActionCreator)
	assert.parameterTypeIsTable('dependencies', dependencies)
	assert.parameterTypeIsTable('buildVariant', buildVariant)
	assert.parameterTypeIsFunctionOrCall('unsetEnvironmentVariableActionCreator', unsetEnvironmentVariableActionCreator)
	assert.parameterTypeIsFunctionOrCall('exportEnvironmentVariableActionCreator', exportEnvironmentVariableActionCreator)
	
	AbstractShellScriptAction.initialize(self)
	
	self.dependencies = dependencies
	self.buildVariant = buildVariant
	self.unsetEnvironmentVariableAction = unsetEnvironmentVariableActionCreator(shellScript)
	self.exportEnvironmentVariableAction = exportEnvironmentVariableActionCreator(shellScript)
end

function module:_newCCompilerDriverArguments(crossRecipePaths, compilerDriverFlags)
	return crossRecipePaths.platform.cCompilerDriver:newArguments(compilerDriverFlags, crossRecipePaths.platformPaths:sysroot(), true)
end

function module:_unsetEnvironmentVariables(compilerDriverArguments)
	local compilerDriver = compilerDriverArguments.compilerDriver
	
	compilerDriver:unsetEnvironmentVariables(function(environmentVariableName)
		self.unsetEnvironmentVariableAction:execute(shellScript, environmentVariableName)
	end)
end

function module:_exportEnvironmentVariables(compilerDriverArguments, extras)
	local compilerDriver = compilerDriverArguments.compilerDriver
	
	compilerDriver:exportEnvironmentVariables(function(environmentVariableName, environmentVariableValue)
		self.exportEnvironmentVariableAction:execute(shellScript, environmentVariableName, environmentVariableValue)
	end, extras)
end
