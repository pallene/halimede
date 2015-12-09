--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local RecipePaths = halimede.build.toolchain.RecipePaths
local CStandard = halimede.build.toolchain.CStandard
local LegacyCandCPlusPlusStringLiteralEncoding = halimede.build.toolchain.LegacyCandCPlusPlusStringLiteralEncoding
local CommandLineDefines = halimede.build.defines.CommandLineDefines
local AbstractCompilerDriverShellScriptAction = require.sibling('AbstractCompilerDriverShellScriptAction')
local Path = halimede.io.paths.Path


moduleclass('AbstractPreprocessCompileAssembleAndExecutableLinkCompilerDriverShellScriptAction', AbstractCompilerDriverShellScriptAction)

function module:initialize(dependencies, buildVariant, unsetEnvironmentVariableActionCreator, exportEnvironmentVariableActionCreator)
	AbstractCompilerDriverShellScriptAction.initialize(self, dependencies, buildVariant, unsetEnvironmentVariableActionCreator, exportEnvironmentVariableActionCreator)
end

function module:execute(shellScript, crossRecipePaths, compilerDriverFlags, cStandard, legacyCandCPlusPlusStringLiteralEncoding, preprocessorFlags, defines, sources, linkerFlags, linkedLibraries, baseName)
	assert.parameterTypeIsInstanceOf('crossRecipePaths', crossRecipePaths, RecipePaths)
	assert.parameterTypeIsTable('compilerDriverFlags', compilerDriverFlags)
	assert.parameterTypeIsInstanceOf('cStandard', cStandard, CStandard)
	assert.parameterTypeIsInstanceOf('legacyCandCPlusPlusStringLiteralEncoding', legacyCandCPlusPlusStringLiteralEncoding, LegacyCandCPlusPlusStringLiteralEncoding)
	assert.parameterTypeIsTable('preprocessorFlags', preprocessorFlags)
	assert.parameterTypeIsInstanceOf('defines', defines, CommandLineDefines)
	assert.parameterTypeIsTable('sources', sources)
	assert.parameterTypeIsTable('linkerFlags', linkerFlags)
	assert.parameterTypeIsTable('linkedLibraries', linkedLibraries)
	assert.parameterTypeIsString('baseName', baseName)
	
	local compilerDriverArguments = self:_newCCompilerDriverArguments(crossRecipePaths, compilerDriverFlags)
	compilerDriverArguments:addCStandard(cStandard)
	compilerDriverArguments:useFileExtensionsToDetermineLanguage()
	compilerDriverArguments:append(preprocessorFlags)
	defines:appendToCompilerDriverArguments(compilerDriverArguments)
	compilerDriverArguments:addSystemIncludePaths(self.dependencies.systemIncludePaths, self.buildVariant.systemIncludePaths)
	compilerDriverArguments:addIncludePaths(self.shellScript.shellLanguage.pathStyle.currentDirectory, sources)
	compilerDriverArguments:addLinkerFlags(self.dependencies.linkerFlags, self.buildVariant.linkerFlags, linkerFlags)
	compilerDriverArguments:appendFilePaths(sources)
	compilerDriverArguments:addLinkedLibraries(self.dependencies.libs, self.buildVariant.libs, linkedLibraries)
	compilerDriverArguments:addOutput(crossRecipePaths:toExecutableRelativeFilePath(baseName))
	
	self:_unsetEnvironmentVariables(compilerDriverArguments)
	self:_exportEnvironmentVariables(compilerDriverArguments, {'LANG', legacyCandCPlusPlusStringLiteralEncoding.value})
	
	compilerDriverArguments:useUnpacked(function(...)
		shellScript:appendCommandLineToScript(...)
	end)
end
