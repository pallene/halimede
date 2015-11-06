--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractCompilerDriverShellScriptAction = requireSibling('AbstractPosixShellScriptAction')
moduleclass('AbstractExecutableLinkCompilerDriverShellScriptAction', AbstractCompilerDriverShellScriptAction)

local Toolchain = requireSibling('Toolchain')


function module:initialize(shellScript, dependencies, buildVariant, unsetEnvironmentVariableActionCreator, exportEnvironmentVariableActionCreator)
	AbstractCompilerDriverShellScriptAction.initialize(self, shellScript, dependencies, buildVariant, unsetEnvironmentVariableActionCreator, exportEnvironmentVariableActionCreator)
end

function module:execute(toolchain, compilerDriverFlags, linkerFlags, objects, linkedLibraries, baseName)
	assert.parameterTypeIsInstanceOf(toolchain, Toolchain)
	assert.parameterTypeIsBoolean(crossCompile)
	assert.parameterTypeIsTable(compilerDriverFlags)
	assert.parameterTypeIsTable(linkerFlags)
	assert.parameterTypeIsTable(objects)
	assert.parameterTypeIsTable(additionalLinkedLibraries)
	assert.parameterTypeIsString(baseName)
	
	local compilerDriverArguments = self._newCCompilerDriverArguments(toolchain, compilerDriverFlags)
	compilerDriverArguments:addLinkerFlags(self.dependencies.linkerFlags, self.buildVariant.linkerFlags, linkerFlags)
	compilerDriverArguments:append(objects)
	compilerDriverArguments:addLinkedLibraries(self.dependencies.linkedLibraries, self.buildVariant.linkedLibraries, linkedLibraries)
	
	self:_unsetEnvironmentVariables(compilerDriverArguments)
	self:_exportEnvironmentVariables(compilerDriverArguments, {'LANG', legacyCandCPlusPlusStringLiteralEncoding.value})
	
	compilerDriverArguments:useUnpacked(function(...)
		self:_appendCommandLineToScript(...)
	end)
end
