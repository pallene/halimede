--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local Path = halimede.io.paths.Path
local ShellPath = halimede.io.shellScript.ShellPath
local CStandard = halimede.build.toolchain.CStandard
local LegacyCandCPlusPlusStringLiteralEncoding = halimede.build.toolchain.LegacyCandCPlusPlusStringLiteralEncoding
local CommandLineDefines = halimede.build.defines.CommandLineDefines
local AbstractCompilerDriverShellScriptAction = require.sibling.AbstractCompilerDriverShellScriptAction


moduleclass('AbstractPreprocessCompileAssembleAndExecutableLinkCompilerDriverShellScriptAction', AbstractCompilerDriverShellScriptAction)

function module:initialize(dependencies, buildVariant, unsetEnvironmentVariableActionClass, exportEnvironmentVariableActionClass)
	AbstractCompilerDriverShellScriptAction.initialize(self, dependencies, buildVariant, unsetEnvironmentVariableActionClass, exportEnvironmentVariableActionClass)
end

function module:_execute(shellScript, builder, compilerDriverFlags, cStandard, legacyCandCPlusPlusStringLiteralEncoding, preprocessorFlags, defines, sources, linkerFlags, linkedLibraries, executableFilePathWithoutExtension)
	assert.parameterTypeIsTable('compilerDriverFlags', compilerDriverFlags)
	assert.parameterTypeIsInstanceOf('cStandard', cStandard, CStandard)
	assert.parameterTypeIsInstanceOf('legacyCandCPlusPlusStringLiteralEncoding', legacyCandCPlusPlusStringLiteralEncoding, LegacyCandCPlusPlusStringLiteralEncoding)
	assert.parameterTypeIsTable('preprocessorFlags', preprocessorFlags)
	assert.parameterTypeIsInstanceOf('defines', defines, CommandLineDefines)
	assert.parameterTypeIsTable('sources', sources)
	assert.parameterTypeIsTable('linkerFlags', linkerFlags)
	assert.parameterTypeIsTable('linkedLibraries', linkedLibraries)
	assert.parameterTypeIsInstanceOf('executableFilePathWithoutExtension', executableFilePathWithoutExtension, ShellPath)
	
	executableFilePathWithoutExtension:assertIsFilePath('executableFilePathWithoutExtension')
	
	local crossRecipePaths = builder.crossRecipePaths
	
	local compilerDriverArguments = self:_newCCompilerDriverArguments(crossRecipePaths, compilerDriverFlags)
	compilerDriverArguments:addCStandard(cStandard)
	compilerDriverArguments:useFileExtensionsToDetermineLanguage()
	compilerDriverArguments:append(preprocessorFlags)
	defines:appendToCompilerDriverArguments(compilerDriverArguments)
	compilerDriverArguments:addSystemIncludePaths(self.dependencies.systemIncludePaths, self.buildVariant.systemIncludePaths)
	compilerDriverArguments:addIncludePaths(shellScript.shellLanguage.pathStyle.currentDirectory, sources)
	compilerDriverArguments:addLinkerFlags(self.dependencies.linkerFlags, self.buildVariant.linkerFlags, linkerFlags)
	compilerDriverArguments:appendFilePaths(sources)
	compilerDriverArguments:addLinkedLibraries(self.dependencies.libs, self.buildVariant.libs, linkedLibraries)
	compilerDriverArguments:addOutput(crossRecipePaths:toExecutableRelativeFilePath(executableFilePathWithoutExtension))
	
	self:_unsetEnvironmentVariables(shellScript, builder, compilerDriverArguments)
	self:_exportEnvironmentVariables(shellScript, builder, compilerDriverArguments, {'LANG', legacyCandCPlusPlusStringLiteralEncoding.value})
	
	compilerDriverArguments:appendCommandLineToScript(shellScript)
end
