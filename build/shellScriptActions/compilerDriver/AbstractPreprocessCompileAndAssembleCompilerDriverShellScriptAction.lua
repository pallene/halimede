--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Toolchain = halimede.build.toolchain.Toolchain
local CStandard = halimede.build.toolchain.CStandard
local LegacyCandCPlusPlusStringLiteralEncoding = halimede.build.toolchain.LegacyCandCPlusPlusStringLiteralEncoding
local CommandLineDefines = halimede.build.defines.CommandLineDefines
local AbstractCompilerDriverShellScriptAction = require.sibling('AbstractCompilerDriverShellScriptAction')


moduleclass('AbstractPreprocessCompileAndAssembleCompilerDriverShellScriptAction', AbstractCompilerDriverShellScriptAction)

function module:initialize(shellScript, dependencies, buildVariant, unsetEnvironmentVariableActionCreator, exportEnvironmentVariableActionCreator)
	AbstractCompilerDriverShellScriptAction.initialize(self, shellScript, dependencies, buildVariant, unsetEnvironmentVariableActionCreator, exportEnvironmentVariableActionCreator)
end

function module:execute(toolchain, compilerDriverFlags, cStandard, legacyCandCPlusPlusStringLiteralEncoding, preprocessorFlags, defines, sources)
	assert.parameterTypeIsInstanceOf('toolchain', toolchain, Toolchain)
	assert.parameterTypeIsTable('compilerDriverFlags', compilerDriverFlags)
	assert.parameterTypeIsInstanceOf('cStandard', cStandard, CStandard)
	assert.parameterTypeIsInstanceOf('legacyCandCPlusPlusStringLiteralEncoding', legacyCandCPlusPlusStringLiteralEncoding, LegacyCandCPlusPlusStringLiteralEncoding)
	assert.parameterTypeIsTable('preprocessorFlags', preprocessorFlags)
	assert.parameterTypeIsInstanceOf('defines', defines, CommandLineDefines)
	assert.parameterTypeIsTable('sources', sources)
	
	local compilerDriverArguments = self:_newCCompilerDriverArguments(toolchain, compilerDriverFlags)
	compilerDriverArguments:append(compilerDriverArguments.compilerDriver.onlyRunPreprocessorCompilationAndAssembleStepsFlags)
	compilerDriverArguments:addCStandard(cStandard)
	compilerDriverArguments:useFileExtensionsToDetermineLanguage()
	compilerDriverArguments:append(preprocessorFlags)
	defines:appendToCompilerDriverArguments(compilerDriverArguments)
	compilerDriverArguments:addSystemIncludePaths(self.dependencies.systemIncludePaths, self.buildVariant.systemIncludePaths)
	compilerDriverArguments:addIncludePaths(sources)
	compilerDriverArguments:appendFilePaths(sources)
	
	self:_unsetEnvironmentVariables(compilerDriverArguments)
	self:_exportEnvironmentVariables(compilerDriverArguments, {'LANG', legacyCandCPlusPlusStringLiteralEncoding.value})
	
	compilerDriverArguments:useUnpacked(function(...)
		self:_appendCommandLineToScript(...)
	end)
end
