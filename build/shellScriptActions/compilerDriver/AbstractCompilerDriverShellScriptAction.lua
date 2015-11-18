--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--

local AbstractShellScriptAction = require('halimede.build.shellScriptActions.AbstractShellScriptAction')
moduleclass('AbstractCompilerDriverShellScriptAction', AbstractShellScriptAction)

local assert = require('halimede').assert


function module:initialize(shellScript, dependencies, buildVariant, unsetEnvironmentVariableActionCreator, exportEnvironmentVariableActionCreator)
	assert.parameterTypeIsFunctionOrCall('unsetEnvironmentVariableActionCreator', unsetEnvironmentVariableActionCreator)
	assert.parameterTypeIsFunctionOrCall('exportEnvironmentVariableActionCreator', exportEnvironmentVariableActionCreator)
	assert.parameterTypeIsTable('dependencies', dependencies)
	assert.parameterTypeIsTable('buildVariant', buildVariant)
	
	AbstractShellScriptAction.initialize(self, shellScript)
	
	self.dependencies = dependencies
	self.buildVariant = buildVariant
	self.unsetEnvironmentVariableAction = unsetEnvironmentVariableActionCreator(shellScript)
	self.exportEnvironmentVariableAction = exportEnvironmentVariableActionCreator(shellScript)
end

function AbstractCompileUnitActions:_newCCompilerDriverArguments(toolchain, compilerDriverFlags)
	return toolchain.platform.cCompilerDeriver:newArguments(compilerDriverFlags, toolchain.sysrootPath)
end

function module:_unsetEnvironmentVariables(compilerDriverArguments)
	local compilerDriver = compilerDriverArguments.compilerDriver
	
	compilerDriver:unsetEnvironmentVariables(function(environmentVariableName)
		self.unsetEnvironmentVariableAction.execute(environmentVariableName)
	end)
end

function module:_exportEnvironmentVariables(compilerDriverArguments, extras)
	local compilerDriver = compilerDriverArguments.compilerDriver
	
	compilerDriver:unsetEnvironmentVariables(function(environmentVariableName, environmentVariableValue)
		self.exportEnvironmentVariableAction.execute(environmentVariableName, environmentVariableValue)
	end, extras)
end