--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractCompilerDriverShellScriptAction = require.sibling('AbstractPosixShellScriptAction')
moduleclass('AbstractPreprocessCompileAndAssembleCompilerDriverShellScriptAction', AbstractCompilerDriverShellScriptAction)

local Toolchain = require.sibling('Toolchain')
local CStandard = halimede.build.toolchain.CStandard')
local LegacyCandCPlusPlusStringLiteralEncoding = halimede.build.toolchain.LegacyCandCPlusPlusStringLiteralEncoding')
local CommandLineDefines = halimede.build.defines.CommandLineDefines


function module:initialize(shellScript, unsetEnvironmentVariableActionCreator, exportEnvironmentVariableActionCreator, dependencies, buildVariant)
	AbstractCompilerDriverShellScriptAction.initialize(self, shellScript, unsetEnvironmentVariableActionCreator, exportEnvironmentVariableActionCreator, dependencies, buildVariant)
end

function module:execute(toolchain, compilerDriverFlags, standard, legacyCandCPlusPlusStringLiteralEncoding, preprocessorFlags, defines, sources)
	assert.parameterTypeIsInstanceOf('toolchain', toolchain, Toolchain)
	assert.parameterTypeIsBoolean('crossCompile', crossCompile)
	assert.parameterTypeIsTable('compilerDriverFlags', compilerDriverFlags)
	assert.parameterTypeIsInstanceOf('standard', standard, CStandard)
	assert.parameterTypeIsInstanceOf('legacyCandCPlusPlusStringLiteralEncoding', legacyCandCPlusPlusStringLiteralEncoding, LegacyCandCPlusPlusStringLiteralEncoding)
	assert.parameterTypeIsTable('preprocessorFlags', preprocessorFlags)
	assert.parameterTypeIsInstanceOf('defines', defines, CommandLineDefines)
	assert.parameterTypeIsTable('sources', sources)
	
	local compilerDriverArguments = self._newCCompilerDriverArguments(toolchain, compilerDriverFlags)
	compilerDriverArguments:append(compilerDriver.onlyRunPreprocessorCompilationAndAssembleStepsFlags)
	compilerDriverArguments:addStandard(standard)
	compilerDriverArguments:useFileExtensionsToDetermineLanguageFlags()
	compilerDriverArguments:append(preprocessorFlags)
	defines:appendToCommandLineArguments(compilerDriverArguments)
	compilerDriverArguments:addSystemIncludePaths(self.dependencies.systemIncludePaths, self.buildVariant.systemIncludePaths)
	compilerDriverArguments:addIncludePaths(sources)
	compilerDriverArguments:appendFilePaths(sources)
	
	self:_unsetEnvironmentVariables(compilerDriverArguments)
	self:_exportEnvironmentVariables(compilerDriverArguments, {'LANG', legacyCandCPlusPlusStringLiteralEncoding.value})
	
	compilerDriverArguments:useUnpacked(function(...)
		self:_appendCommandLineToScript(...)
	end)
end
