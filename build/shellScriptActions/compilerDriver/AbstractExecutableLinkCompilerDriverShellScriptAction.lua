--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local Path = halimede.io.paths.Path
local sibling = halimede.build.shellScriptActions.compilerDriver
local AbstractCompilerDriverShellScriptAction = sibling.AbstractCompilerDriverShellScriptAction


halimede.moduleclass('AbstractExecutableLinkCompilerDriverShellScriptAction', AbstractCompilerDriverShellScriptAction)

function module:initialize(dependencies, buildVariant, unsetEnvironmentVariableActionClass, exportEnvironmentVariableActionClass)
	AbstractCompilerDriverShellScriptAction.initialize(self, dependencies, buildVariant, unsetEnvironmentVariableActionClass, exportEnvironmentVariableActionClass)
end

function module:_execute(shellScript, builder, compilerDriverFlags, linkerFlags, objects, linkedLibraries, executableFilePathWithoutExtension)
	assert.parameterTypeIsTable('compilerDriverFlags', compilerDriverFlags)
	assert.parameterTypeIsTable('linkerFlags', linkerFlags)
	assert.parameterTypeIsTable('objects', objects)
	assert.parameterTypeIsTable('linkedLibraries', linkedLibraries)
	assert.parameterTypeIsInstanceOf('executableFilePathWithoutExtension', executableFilePathWithoutExtension, Path)

	executableFilePathWithoutExtension:assertIsFilePath('executableFilePathWithoutExtension')

	local crossRecipePaths = builder.crossRecipePaths
	local executableFilePath = crossRecipePaths:toExecutableRelativeFilePath(executableFilePathWithoutExtension)

	local compilerDriverArguments = self:_newCCompilerDriverArguments(crossRecipePaths, compilerDriverFlags, shellScript.shellLanguage)
	compilerDriverArguments:addLinkerFlags(self.dependencies.linkerFlags, self.buildVariant.linkerFlags, linkerFlags)
	compilerDriverArguments:appendFilePaths(objects)
	compilerDriverArguments:addLinkedLibraries(self.dependencies.libs, self.buildVariant.libs, linkedLibraries)
	compilerDriverArguments:addOutput(executableFilePath)

	self:_unsetEnvironmentVariables(shellScript, builder, compilerDriverArguments)
	self:_exportEnvironmentVariables(shellScript, builder, compilerDriverArguments, {'LANG', 'C'})

	compilerDriverArguments:appendCommandLineToScript(shellScript)
	
	return executableFilePath
end
