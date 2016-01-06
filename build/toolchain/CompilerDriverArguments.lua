--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local CompilerDriver = require.sibling.CompilerDriver
local Arguments = require.sibling.Arguments
local CStandard = require.sibling.CStandard
local Path = halimede.io.paths.Path
local ShellLanguage = halimede.io.shellScript.ShellLanguage
local ShellScript = halimede.io.shellScript.ShellScript


halimede.moduleclass('CompilerDriverArguments')

function module:initialize(compilerDriver, compilerDriverFlags, sysrootPath, isVerbose, shellLanguage)
	assert.parameterTypeIsInstanceOf('compilerDriver', compilerDriver, CompilerDriver)
	assert.parameterTypeIsTable('compilerDriverFlags', compilerDriverFlags)
	assert.parameterTypeIsTable('sysrootPath', sysrootPath)
	assert.parameterTypeIsBoolean('isVerbose', isVerbose)
	assert.parameterTypeIsInstanceOf('shellLanguage', shellLanguage, ShellLanguage)

	self.compilerDriver = compilerDriver

	self.arguments = Arguments:new(shellLanguage)
	self.arguments:append(compilerDriver.commandLineName)
	if isVerbose then
		self.arguments:append(compilerDriver.verboseFlags)
	end
	self.arguments:append(compilerDriver.commandLineFlags)
	self.arguments:append(compilerDriverFlags)
	compilerDriver:appendSystemRoot(self.arguments, sysrootPath)
end

function module:append(...)
	self.arguments:append(...)
end

function module:appendFilePaths(filePaths)
	assert.parameterTypeIsTable('filePaths', filePaths)

	for _, filePath in ipairs(filePaths) do
		filePath:assertIsFilePath('filePath')

		self.arguments:appendQuotedArgumentXWithPrepend('', filePath, true)
	end
end

-- Allows to remap standard names for gcc as they change by version, warn about obsolence, etc
function module:addCStandard(cStandard)
	assert.parameterTypeIsInstanceOf('cStandard', cStandard, CStandard)

	self.compilerDriver:addCStandard(self.arguments, cStandard)
end

function module:useFileExtensionsToDetermineLanguage()
	self.compilerDriver:useFileExtensionsToDetermineLanguage(self.arguments)
end

function module:doNotPredefineSystemOrCompilerDriverMacros()
	self.compilerDriver:doNotPredefineSystemOrCompilerDriverMacros(self.arguments)
end

function module:undefinePreprocessorMacro(defineName)
	assert.parameterTypeIsString('defineName', defineName)

	self.compilerDriver:undefinePreprocessorMacro(self.arguments, defineName)
end

function module:definePreprocessorMacro(defineName, defineValue)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsString('defineValue', defineValue)

	self.compilerDriver:definePreprocessorMacro(self.arguments, defineName, defineValue)
end

function module:addSystemIncludePaths(dependenciesSystemIncludePaths, buildVariantSystemIncludePaths)
	assert.parameterTypeIsTable('dependenciesSystemIncludePaths', dependenciesSystemIncludePaths)
	assert.parameterTypeIsTable('buildVariantSystemIncludePaths', buildVariantSystemIncludePaths)

	self.compilerDriver:addSystemIncludePaths(self.arguments, dependenciesSystemIncludePaths, buildVariantSystemIncludePaths)
end

function module:addIncludePaths(currentPath, sourceFilePaths)
	assert.parameterTypeIsInstanceOf('currentPath', currentPath, Path)
	assert.parameterTypeIsTable('sourceFilePaths', sourceFilePaths)

	self.compilerDriver:addIncludePaths(self.arguments, currentPath, sourceFilePaths)
end

function module:addLinkerFlags(dependenciesLinkerFlags, buildVariantLinkerFlags, otherLinkerFlags)
	assert.parameterTypeIsTable('dependenciesLinkerFlags', dependenciesLinkerFlags)
	assert.parameterTypeIsTable('buildVariantLinkerFlags', buildVariantLinkerFlags)
	assert.parameterTypeIsTable('otherLinkerFlags', otherLinkerFlags)

	self.compilerDriver:addLinkerFlags(self.arguments, dependenciesLinkerFlags, buildVariantLinkerFlags, otherLinkerFlags)
end

function module:addLinkedLibraries(dependenciesLinkedLibraries, buildVariantLinkedLibraries, otherLinkedLibraries)
	assert.parameterTypeIsTable('dependenciesLinkedLibraries', dependenciesLinkedLibraries)
	assert.parameterTypeIsTable('buildVariantLinkedLibraries', buildVariantLinkedLibraries)
	assert.parameterTypeIsTable('otherLinkedLibraries', otherLinkedLibraries)

	self.compilerDriver:addLinkedLibraries(self.arguments, dependenciesLinkedLibraries, buildVariantLinkedLibraries, otherLinkedLibraries)
end

function module:addCombine()
	self.compilerDriver:addCombine(self.arguments)
end

function module:addOutput(outputFilePath)
	assert.parameterTypeIsTable('outputFilePath', outputFilePath)

	outputFilePath:assertIsFilePath('outputFilePath')

	self.compilerDriver:addOutput(self.arguments, outputFilePath)
end

function module:appendCommandLineToScript(shellScript)
	assert.parameterTypeIsInstanceOf('shellScript', shellScript, ShellScript)

	self.arguments:appendCommandLineToScript(shellScript)
end
