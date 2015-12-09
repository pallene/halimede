--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Path = halimede.io.paths.Path
local AbstractCompilerDriverShellScriptAction = require.sibling('AbstractCompilerDriverShellScriptAction')


moduleclass('AbstractExecutableLinkCompilerDriverShellScriptAction', AbstractCompilerDriverShellScriptAction)

function module:initialize(dependencies, buildVariant, unsetEnvironmentVariableActionClass, exportEnvironmentVariableActionClass)
	AbstractCompilerDriverShellScriptAction.initialize(self, dependencies, buildVariant, unsetEnvironmentVariableActionClass, exportEnvironmentVariableActionClass)
end

function module:execute(shellScript, buildEnvironment, compilerDriverFlags, linkerFlags, objects, linkedLibraries, executableFilePathWithoutExtension)
	assert.parameterTypeIsTable('compilerDriverFlags', compilerDriverFlags)
	assert.parameterTypeIsTable('linkerFlags', linkerFlags)
	assert.parameterTypeIsTable('objects', objects)
	assert.parameterTypeIsTable('linkedLibraries', linkedLibraries)
	assert.parameterTypeIsInstanceOf('executableFilePathWithoutExtension', executableFilePathWithoutExtension, Path)
	
	executableFilePathWithoutExtension:assertIsFilePath('executableFilePathWithoutExtension')
	
	local crossRecipePaths = buildEnvironment.crossRecipePaths
	
	local compilerDriverArguments = self:_newCCompilerDriverArguments(crossRecipePaths, compilerDriverFlags)
	compilerDriverArguments:addLinkerFlags(self.dependencies.linkerFlags, self.buildVariant.linkerFlags, linkerFlags)
	compilerDriverArguments:appendFilePaths(objects)
	compilerDriverArguments:addLinkedLibraries(self.dependencies.libs, self.buildVariant.libs, linkedLibraries)
	compilerDriverArguments:addOutput(crossRecipePaths:toExecutableRelativeFilePath(executableFilePathWithoutExtension))
	
	self:_unsetEnvironmentVariables(shellScript, buildEnvironment, compilerDriverArguments)
	self:_exportEnvironmentVariables(shellScript, buildEnvironment, compilerDriverArguments, {'LANG', 'C'})
	
	compilerDriverArguments:appendCommandLineToScript(shellScript)
end
