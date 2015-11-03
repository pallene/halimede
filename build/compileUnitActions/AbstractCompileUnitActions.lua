--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local basename = halimede.basename
local class = require('halimede.middleclass')
local AbsolutePath = require('halimede.io.paths.AbsolutePath')
local toTemporaryFileAllContentsInTextModeAndUse = require('halimede.io.temporaryWrite').toTemporaryFileAllContentsInTextModeAndUse
local commandIsOnPathAndShellIsAvaiableToUseIt = require('halimede.io.commandIsAvailable').commandIsOnPathAndShellIsAvaiableToUseIt
local CStandard = require('halimede.build.defines.CStandard')
local LegacyCandCPlusPlusStringLiteralEncoding = require('LegacyCandCPlusPlusStringLiteralEncoding')
local CommandLineDefines = require('halimede.build.defines.CommandLineDefines')


local AbstractCompileUnitActions = class('AbstractCompileUnitActions')

function AbstractCompileUnitActions:initialize(shellLanguage, sourcePath, sysrootPath, toolchain, dependencies, buildVariant)
	assert.parameterTypeIsTable(shellLanguage)
	assert.parameterTypeIsInstanceOf(sourcePath, AbsolutePath)
	assert.parameterTypeIsInstanceOf(sysrootPath, AbsolutePath)
	assert.parameterTypeIsTable(toolchain)
	assert.parameterTypeIsTable(dependencies)
	assert.parameterTypeIsTable(buildVariant)
	
	self.shellLanguage = shellLanguage
	self.sourcePath = sourcePath
	self.sysrootPath = sysrootPath
	self.toolchain = toolchain
	self.dependencies = dependencies
	self.buildVariant = buildVariant
	
	self.script = tabelize({})
	self._initialBuildScript()
	self.actionChangeDirectory(sourcePath)
end

function AbstractCompileUnitActions:_addToScript(text)
	self.script:insert(text)
end

assert.globalTypeIsFunction('ipairs')
function AbstractCompileUnitActions:appendLinesToBuildScript(...)
	local lines = {...}
	for _, line in ipairs(lines) do
		self:_addToScript(line)
		self:_addToScript(self.shellLanguage.newline)
	end
end

function AbstractCompileUnitActions:appendCommandLineToBuildScript(...)
	self:_addToScript(self.shellLanguage.toShellCommandLine(...))
end

function AbstractCompileUnitActions:actionWriteConfigH()
	-- Do we write this ourselves, now, or do we embed it in the script? The latter has some advantages
	self:appendCommandLineToBuildScript('printf', '%s', configH, self.shellLanguage.redirectOutput('config.h'))
end

assert.globalTypeIsFunction('ipairs')
local function addFlags(arguments, flags)
	for _, flag in flags do
		assert.parameterTypeIsString(flag)
		arguments:insert(flag)
	end
end

function AbstractCompileUnitActions:_chooseCCompilerDriver(crossCompile)
	if crossCompile then
		return self.toolchain.crossPlatform.cCompilerDriver
	else
		-- Actually, this may end up being a bootstrap, etc
		return self.toolchain.buildPlatform.cCompilerDriver
	end
end

function AbstractCompileUnitActions:_prepareCompilerDriver(compilerDriver, compilerDriverFlags)
	
	-- The toolchain controls PATH, target, the need to unset GCC_EXEC_PREFIX, etc
	local arguments = tabelize({})
	
	-- eg 'gcc -march=native'
	addFlags(arguments, compilerDriver.commandLineName)
	addFlags(arguments, compilerDriver.commandLineFlags)
	arguments:insert('--sysroot=' .. self.sysrootPath.path)
	
	return arguments
end

local writeToFileAllContentsInTextMode = require('halimede.io.write').writeToFileAllContentsInTextMode

-- TODO: More complex builds might need to control the path and file name
function AbstractCompileUnitActions:writeConfigH(configH)
	writeToFileAllContentsInTextMode(concatenateToPath(self.sourcePath, 'config.h'), 'config.h', configH:toCPreprocessorText())
end

assert.globalTypeIsFunction('unpack')
function AbstractCompileUnitActions:actionCompilerDriverCPreprocessCompileAndAssemble(crossCompile, compilerDriverFlags, standard, legacyCandCPlusPlusStringLiteralEncoding, preprocessorFlags, defines, sources)
	assert.parameterTypeIsBoolean(crossCompile)
	assert.parameterTypeIsTable(compilerDriverFlags)
	assert.parameterTypeIsInstanceOf(standard, CStandard)
	assert.parameterTypeIsInstanceOf(legacyCandCPlusPlusStringLiteralEncoding, LegacyCandCPlusPlusStringLiteralEncoding)
	assert.parameterTypeIsTable(preprocessorFlags)
	assert.parameterTypeIsInstanceOf(defines, CommandLineDefines)
	assert.parameterTypeIsTable(sources)
	
	local compilerDriver = self:_chooseCCompilerDriver(crossCompile)
	
	local argments = self._prepareCompilerDriver(compilerDriver, compilerDriverFlags)
	addFlags(arguments, compilerDriver.onlyRunPreprocessorCompilationAndAssembleStepsFlags)
	compilerDriver:addStandard(arguments, standard)
	compilerDriver:useFileExtensionsToDetermineLanguageFlags(arguments)
	addFlags(arguments, preprocessorFlags)
	
	defines:appendToCommandLineArguments(compilerDriver, arguments)
	
	-- TODO: There's a complex interplay between build variants and dependencies (some dependencies are the result of build variants)
	compilerDriver:addSystemIncludePaths(arguments, self.dependencies.systemIncludePaths, self.buildVariant.systemIncludePaths)
	
	-- TODO: There's a possibility a second compile in the same unit might want to access the headers in the source tree of a previous compile
	compilerDriver:addIncludePaths(arguments, sources)
	
	-- TODO: We ought to use a subshell, but this isn't easy on Windows (cmd /C)
	compilerDriver:unsetEnvironmentVariables(function(environmentVariableName)
		self:actionUnsetEnvironmentVariable(environmentVariableName)
	end)
	
	compilerDriver:exportEnvironmentVariables(function(environmentVariableName, environmentVariableValue)
		self:actionExportEnvironmentVariable(environmentVariableName, environmentVariableValue)
	end, {'LANG', legacyCandCPlusPlusStringLiteralEncoding.value})
	
	self:appendCommandLineToBuildScript(unpack(arguments))
	
	compilerDrive:endSubshell()
end

-- TODO: Need to add '-L' switches; there's a horrible interaction between sysroot and what gets embedded in the dynamic linker... and RPATH
-- eg pthread, m => several libraries from one compilation unit (c lib on Linux)
assert.globalTypeIsFunction('unpack')
function AbstractCompileUnitActions:compilerDriverLinkCExecutable(crossCompile, compilerDriverFlags, linkerFlags, objects, additionalLinkedLibraries, baseName)
	assert.parameterTypeIsBoolean(crossCompile)
	assert.parameterTypeIsTable(compilerDriverFlags)
	assert.parameterTypeIsTable(linkerFlags)
	assert.parameterTypeIsTable(objects)
	assert.parameterTypeIsTable(additionalLinkedLibraries)
	assert.parameterTypeIsString(baseName)
	
	local compilerDriver = self:_chooseCCompilerDriver(crossCompile)
	
	local argments = self._prepareCompilerDriver(compilerDriver, compilerDriverFlags)
	addFlags(arguments, compilerDriver:mergeFlags(compilerDriver.linkerFlags, self.dependencies.linkerFlags, linkerFlags))
	addFlags(arguments, objects)
	for _, linkedLibrary in ipairs(compilerDriver:mergeFlags(compilerDriver.additionalLinkedLibraries, self.dependencies.additionalLinedLibraries, additionalLinkedLibraries)) do
		arguments:insert('-l' .. linkedLibrary)
	end
	
	compilerDriver:unsetEnvironmentVariables(function(environmentVariableName)
		self:actionUnsetEnvironmentVariable(environmentVariableName)
	end)
	
	compilerDriver:exportEnvironmentVariables(function(environmentVariableName, environmentVariableValue)
		self:actionExportEnvironmentVariable(environmentVariableName, environmentVariableValue)
	end, {})
	
	self:appendCommandLineToBuildScript(unpack(arguments))
end

function AbstractCompileUnitActions:executeScript()
	self._finishBuildScript()
	local script = self.script:concat()
	
	toTemporaryFileAllContentsInTextModeAndUse(script, function(temporaryFilePath)
		
		if self.toolchain.isMacOSX and commandIsOnPathAndShellIsAvaiableToUseIt('brew') then
			executeExpectingSuccess(temporaryFilePath, noRedirection, noRedirection, 'brew', 'sh')
		else
			executeExpectingSuccess(noRedirection, noRedirection, noRedirection, 'sh', temporaryFilePath)
		end
	end)
end

return AbstractCompileUnitActions
