--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractCompilerDriverShellScriptAction = requireSibling('AbstractPosixShellScriptAction')
moduleclass('PreprocessCompileAndAssembleCompilerDriverShellScriptAction', AbstractCompilerDriverShellScriptAction)


function module:initialize(shellScript, unsetEnvironmentVariableActionCreator, exportEnvironmentVariableActionCreator, buildToolchain, crossToolchain, dependencies, buildVariant, sourcePath)
	AbstractCompilerDriverShellScriptAction.initialize(self, shellScript, buildToolchain, crossToolchain, dependencies, buildVariant, sourcePath)
end

function module:execute(crossCompile, compilerDriverFlags, standard, legacyCandCPlusPlusStringLiteralEncoding, preprocessorFlags, defines, sources)
	assert.parameterTypeIsBoolean(crossCompile)
	assert.parameterTypeIsTable(compilerDriverFlags)
	assert.parameterTypeIsInstanceOf(standard, CStandard)
	assert.parameterTypeIsInstanceOf(legacyCandCPlusPlusStringLiteralEncoding, LegacyCandCPlusPlusStringLiteralEncoding)
	assert.parameterTypeIsTable(preprocessorFlags)
	assert.parameterTypeIsInstanceOf(defines, CommandLineDefines)
	assert.parameterTypeIsTable(sources)
	
	local toolchain = self:_chooseToolchain(crossCompile)
	
	local compilerDriverArguments = self._newCCompilerDriverArguments(toolchain, compilerDriverFlags)
	compilerDriverArguments:append(compilerDriver.onlyRunPreprocessorCompilationAndAssembleStepsFlags)
	compilerDriverArguments:addStandard(standard)
	compilerDriverArguments:useFileExtensionsToDetermineLanguageFlags()
	compilerDriverArguments:append(preprocessorFlags)
	defines:appendToCommandLineArguments(compilerDriverArguments)
	compilerDriverArguments:addSystemIncludePaths(self.dependencies.systemIncludePaths, self.buildVariant.systemIncludePaths)
	compilerDriverArguments:addIncludePaths(sources)
	compilerDriverArguments:append(sources)
	
	self:_unsetEnvironmentVariables(compilerDriverArguments)
	self:_exportEnvironmentVariables(compilerDriverArguments, {'LANG', legacyCandCPlusPlusStringLiteralEncoding.value})
	
	compilerDriverArguments:useUnpacked(function(...)
		self:_appendCommandLineToScript(...)
	end)
end
