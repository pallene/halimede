--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--

local AbstractShellScriptAction = require('halimede.build.shellScriptActions.AbstractShellScriptAction')
moduleclass('AbstractCompilerDriverShellScriptAction', AbstractShellScriptAction)

local assert = require('halimede').assert
local CStandard = require('halimede.build.toolchain.CStandard')
local LegacyCandCPlusPlusStringLiteralEncoding = require('halimede.build.toolchain.LegacyCandCPlusPlusStringLiteralEncoding')
local CommandLineDefines = require('halimede.build.defines.CommandLineDefines')


-- These unsetEnvironmentVariableActionCreator and exportEnvironmentVariableActionCreator are for either Cmd or Posix (or any other shell in the future, perhaps PowerShell or CScript)
function module:initialize(shellScript, unsetEnvironmentVariableActionCreator, exportEnvironmentVariableActionCreator, buildToolchain, crossToolchain, dependencies, buildVariant, sourcePath)
	assert.parameterTypeIsFunctionOrCall(unsetEnvironmentVariableActionCreator)
	assert.parameterTypeIsFunctionOrCall(exportEnvironmentVariableActionCreator)
	assert.parameterTypeIsInstanceOf(buildToolchain, Toolchain)
	assert.parameterTypeIsInstanceOf(crossToolchain, Toolchain)
	assert.parameterTypeIsTable(dependencies)
	assert.parameterTypeIsTable(buildVariant)
	assert.parameterTypeIsInstanceOf(sourcePath, AbsolutePath)
	
	AbstractShellScriptAction.initialize(self, shellScript)
	
	-- eg UnsetEnvironmentVariablePosixShellScriptAction:new()
	self.unsetEnvironmentVariableAction = unsetEnvironmentVariableActionCreator(shellScript)
	self.exportEnvironmentVariableAction = exportEnvironmentVariableActionCreator(shellScript)
	self.buildToolchain = buildToolchain
	self.crossToolchain = crossToolchain
	self.dependencies = dependencies
	self.buildVariant = buildVariant
	self.sourcePath = sourcePath
end

function AbstractCompileUnitActions:_chooseToolchain(crossCompile)
	if crossCompile then
		return self.crossToolchain
	else
		return self.buildToolchain
	end
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