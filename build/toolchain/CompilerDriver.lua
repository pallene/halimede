--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('halimede.middleclass')
local CompilerMetadata = requireSibling('CompilerMetadata')
local CStandard = requireSibling('CStandard')


local CompilerDriver = class('CompilerDriver')

function CompilerDriver:initialize(compilerMetadata, commandLineFlags, onlyRunPreprocessorStepFlags, onlyRunPreprocessorAndCompilationStepsFlags, onlyRunPreprocessorCompilationAndAssembleStepsFlags, useFileExtensionsToDetermineLanguageFlags, environmentVariablesToUnset, gcc4X_environmentVariablesToExport)
	assert.parameterTypeIsInstanceOf(CompilerMetadata, compilerMetadata)
	assert.parameterTypeIsTable(commandLineFlags)
	assert.parameterTypeIsTable(onlyRunPreprocessorStepFlags)
	assert.parameterTypeIsTable(onlyRunPreprocessorAndCompilationStepsFlags)
	assert.parameterTypeIsTable(onlyRunPreprocessorCompilationAndAssembleStepsFlags)
	assert.parameterTypeIsTable(useFileExtensionsToDetermineLanguageFlags)

	assert.parameterTypeIsTable(environmentVariablesToUnset)
	assert.parameterTypeIsTable(gcc4X_environmentVariablesToExport)
	
	self.compilerMetadata = compilerMetadata
	self.commandLineFlags = commandLineFlags
	self.onlyRunPreprocessorStepFlags = onlyRunPreprocessorStepFlags
	self.onlyRunPreprocessorAndCompilationStepsFlags = onlyRunPreprocessorAndCompilationStepsFlags
	self.onlyRunPreprocessorCompilationAndAssembleStepsFlags = onlyRunPreprocessorCompilationAndAssembleStepsFlags
	self.useFileExtensionsToDetermineLanguageFlags = useFileExtensionsToDetermineLanguageFlags
	self.environmentVariablesToUnset = environmentVariablesToUnset
	self.gcc4X_environmentVariablesToExport = gcc4X_environmentVariablesToExport
	
	-- Override for, say, 'cc' or 'gcc-4.8' or 'x86-pc-linux-musl-gcc-4.8'
	self.commandLineName = self.compilerMetadata.name
	
	self.standardOption = '-std='
	self.undefOption = '-undef'
	self.undefineOption = '-U'
	self.defineOption = '-D'
	self.systemIncludePathOption = '-isystem'
	self.includePathOption = '-I'
end

assert.globalTypeIsFunction('ipairs')
local function addFlags(arguments, flags)
	for _, flag in flags do
		assert.parameterTypeIsString(flag)
		arguments:insert(flag)
	end
end

-- Allows to remap standard names for gcc as they change by version, warn about obsolence, etc
function CompilerDriver:useFileExtensionsToDetermineLanguageFlags(arguments)
	assert.parameterTypeIsTable(arguments)
	
	addFlags(arguments, self.useFileExtensionsToDetermineLanguageFlags)
end

-- Allows to remap standard names for gcc as they change by version, warn about obsolence, etc
function CompilerDriver:addCStandard(arguments, cStandard)
	assert.parameterTypeIsTable(arguments)
	assert.parameterTypeIsInstanceOf(CStandard, cStandard)
	
	arguments:insert(self.standardOption .. cStandard.value)
end

function CompilerDriver:doNotPredefineSystemOrCompilerDriverMacros(arguments)
	assert.parameterTypeIsTable(arguments)

	arguments:insert(self.undefOption)
end

function CompilerDriver:undefinePreprocessorMacro(arguments, defineName)
	assert.parameterTypeIsTable(arguments)
	assert.parameterTypeIsString(defineName)

	arguments:insert(self.undefineOption .. defineName)
end

function CompilerDriver:definePreprocessorMacro(arguments, defineName, defineValue)
	assert.parameterTypeIsTable(arguments)
	assert.parameterTypeIsString(defineName)
	assert.parameterTypeIsString(defineValue)

	arguments:insert(self.defineOption .. defineName .. '=' .. defineValue)
end

local function populateIncludePaths(includePaths, includePath)
	if includePaths[includePath] == nil then
		includePaths[includePath] = true
	end
end

assert.globalTypeIsFunction('ipairs', 'pairs')
function CompilerDriver:addSystemIncludePaths(arguments, dependenciesSystemIncludePaths, buildVariantSystemIncludePaths)
	assert.parameterTypeIsTable(arguments)
	assert.parameterTypeIsTable(dependenciesSystemIncludePaths)
	assert.parameterTypeIsTable(buildVariantSystemIncludePaths)
	
	local systemIncludePaths = {}
	for _, systemIncludePath in ipairs(mergeFlags(compilerDriver.systemIncludePaths, dependenciesSystemIncludePaths, buildVariantSystemIncludePaths)) do
		populateIncludePaths(systemIncludePaths, systemIncludePath)
	end
	
	for systemIncludePath, _ in pairs(systemIncludePaths) do
		arguments:insert(self.systemIncludePathOption .. systemIncludePath)
	end	
end

assert.globalTypeIsFunction('ipairs', 'pairs')
local dirname = halimede.dirname
function CompilerDriver:addIncludePaths(arguments, sources)
	assert.parameterTypeIsTable(arguments)
	assert.parameterTypeIsTable(sources)
	
	local includePaths = {}
	for _, sourceFileRelativePath in ipairs(sources) do
		populateIncludePaths(includePaths, dirname(sourceFileRelativePath))
	end
	for includePath, _ in pairs(includePaths) do
		arguments:insert(self.includePathOption .. includePath)
	end	
end

assert.globalTypeIsFunction('ipairs')
function CompilerDriver:unsetEnvironmentVariables(unsetEnvironmentVariableFunction)
	assert.parameterTypeIsFunctionOrCall(unsetEnvironmentVariableFunction)
	
	for _, environmentVariableName in ipairs(self.environmentVariablesToUnset) do
		unsetEnvironmentVariableFunction(environmentVariableName)
	end
end

assert.globalTypeIsFunction('pairs')
function CompilerDriver:exportEnvironmentVariables(exportEnvironmentVariableFunction, environmentVariableOverrides)
	assert.parameterTypeIsFunctionOrCall(exportEnvironmentVariableFunction)
	assert.parameterTypeIsTable(environmentVariableOverrides)
	
	for environmentVariableName, environmentVariableValue in pairs(self.environmentVariablesToExport) do
		local actualValue
		actualValue = environmentVariableOverrides[environmentVariableName]
		if actualValue == nil then
			actualValue = environmentVariableValue
		end
		exportEnvironmentVariableFunction(environmentVariableName, actualValue)
	end
end

local gcc4XAndClang3X_commandLineFlags = {
	'-pipe',
	'-mtune=native',
	'-march=native'
}
local gcc4XAndClang3X_onlyRunPreprocessorStepFlags = {'-E'}
local gcc4XAndClang3X_onlyRunPreprocessorSAndCompilationStepsFlags = {'-S'}
local gcc4XAndClang3X_onlyRunPreprocessorCompilationAndAssembleStepsFlags = {'-c'}
local gcc4XAndClang3X_useFileExtensionsToDetermineLanguageFlags = {'-x', 'none'}

local gcc4X_environmentVariablesToUnset = {'LANG', 'LC_CTYPE', 'LC_MESSAGES', 'LC_ALL', 'TMPDIR', 'GCC_COMPARE_DEBUG', 'GCC_EXEC_PREFIX', 'COMPILER_PATH', 'LIBRARY_PATH', 'LANG', 'CPATH', 'C_INCLUDE_PATH', 'CPLUS_INCLUDE_PATH', 'OBJC_INCLUDE_PATH', 'DEPENDENCIES_OUTPUT', 'SUNPRO_DEPENDENCIES'}
local gcc4X_environmentVariablesToExport = {LANG = 'C', LC_CTYPE = 'C', LC_MESSAGES = 'C', LC_ALL = 'C'}

-- 'native' and 'generic' are dangerous, in that they change in gcc releases
-- '-pipe' might not work on some systems (?weird windows ones?)
CompilerDriver.static.gcc49_systemNativeHostX86_64 = CompilerDriver:new(CompilerMetadata['gcc 4.9'], gcc4XAndClang3X_onlyRunPreprocessorStepFlags, gcc4XAndClang3X_onlyRunPreprocessorSAndCompilationStepsFlags, gcc4XAndClang3X_onlyRunPreprocessorCompilationAndAssembleStepsFlags, gcc4XAndClang3X_useFileExtensionsToDetermineLanguageFlags, gcc4X_environmentVariablesToUnset, gcc4X_environmentVariablesToExport)
CompilerDriver.static.gccxx49_systemNativeHostX86_64 = CompilerDriver:new(CompilerMetadata['g++ 4.9'], gcc4XAndClang3X_onlyRunPreprocessorStepFlags, gcc4XAndClang3X_onlyRunPreprocessorSAndCompilationStepsFlags, gcc4XAndClang3X_onlyRunPreprocessorCompilationAndAssembleStepsFlags, gcc4XAndClang3X_useFileExtensionsToDetermineLanguageFlags, gcc4X_environmentVariablesToUnset, gcc4X_environmentVariablesToExport)
CompilerDriver.static.clang34_systemNativeHostX86_64 = CompilerDriver:new(CompilerMetadata['clang 3.4'], gcc4XAndClang3X_onlyRunPreprocessorStepFlags, gcc4XAndClang3X_onlyRunPreprocessorSAndCompilationStepsFlags, gcc4XAndClang3X_onlyRunPreprocessorCompilationAndAssembleStepsFlags, gcc4XAndClang3X_useFileExtensionsToDetermineLanguageFlags, gcc4X_environmentVariablesToUnset, gcc4X_environmentVariablesToExport)
CompilerDriver.static.clangxx34_systemNativeHostX86_64 = CompilerDriver:new(CompilerMetadata['clang++ 3.4'], gcc4XAndClang3X_onlyRunPreprocessorStepFlags, gcc4XAndClang3X_onlyRunPreprocessorSAndCompilationStepsFlags, gcc4XAndClang3X_onlyRunPreprocessorCompilationAndAssembleStepsFlags, gcc4XAndClang3X_useFileExtensionsToDetermineLanguageFlags, gcc4X_environmentVariablesToUnset, gcc4X_environmentVariablesToExport)

return CompilerDriver
