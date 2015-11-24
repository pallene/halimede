--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local CompilerDriver = moduleclass('CompilerDriver')

local halimede = require('halimede')
local tabelize = halimede.table.tabelize
local exception = halimede.exception
local CompilerMetadata = requireSibling('CompilerMetadata')
local CStandard = requireSibling('CStandard')
local Path = halimede.io.paths.Path')
local Arguments = requireSibling('Arguments')
local FilePaths = requireSibling('FilePaths')


function module:initialize(compilerMetadata, commandLineFlags, onlyRunPreprocessorStepFlags, onlyRunPreprocessorAndCompilationStepsFlags, onlyRunPreprocessorCompilationAndAssembleStepsFlags, useFileExtensionsToDetermineLanguageFlags, environmentVariablesToUnset, gcc4X_environmentVariablesToExport)
	assert.parameterTypeIsInstanceOf('CompilerMetadata', compilerMetadata, CompilerMetadata)
	assert.parameterTypeIsTable('commandLineFlags', commandLineFlags)
	assert.parameterTypeIsTable('onlyRunPreprocessorStepFlags', onlyRunPreprocessorStepFlags)
	assert.parameterTypeIsTable('onlyRunPreprocessorAndCompilationStepsFlags', onlyRunPreprocessorAndCompilationStepsFlags)
	assert.parameterTypeIsTable('onlyRunPreprocessorCompilationAndAssembleStepsFlags', onlyRunPreprocessorCompilationAndAssembleStepsFlags)
	assert.parameterTypeIsTable('useFileExtensionsToDetermineLanguageFlags', useFileExtensionsToDetermineLanguageFlags)
	assert.parameterTypeIsTable('environmentVariablesToUnset', environmentVariablesToUnset)
	assert.parameterTypeIsTable('gcc4X_environmentVariablesToExport', gcc4X_environmentVariablesToExport)
	
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
	
	self.systemIncludePaths = {}
	self.linkerFlags = {}
	self.linkedLibraries = {}
	
	self.sysrootPathOption = '--sysroot='
	self.standardOption = '-std='
	self.undefOption = '-undef'
	self.undefineOption = '-U'
	self.defineOption = '-D'
	self.systemIncludePathOption = '-isystem'
	self.includePathOption = '-I'
	self.linkedLibraryOption = '-l'
end

assert.globalTypeIsFunction('ipairs')
local function mergeFlags(...)
	local result = tabelize()
	for _, flagSet in ipairs({...}) do
		if type.isString(flagSet) then
			result:insert(flagSet)
		elseif type.isTable(flagSet) then
			for _, flag in ipairs(flagSet) do
				if not type.isString(flag) then
					exception.throw('Argument to mergeFlags can either be string or table of strings (array)')
				end
				result:insert(flag)
			end
		else
			exception.throw('Argument to mergeFlags can either be string or table of strings (array)')
		end
	end
	
	return result	
end

function module:newArguments(compilerDriverFlags, sysrootPath)
	return CompilerDriverArguments:new(self, compilerDriverFlags, sysrootPath)
end

function module:useFileExtensionsToDetermineLanguageFlags(arguments)
	assert.parameterTypeIsInstanceOf('arguments', arguments, Arguments)

	arguments:append(self.useFileExtensionsToDetermineLanguageFlags)
end

function module:appendSystemRoot(arguments, sysrootPath)
	assert.parameterTypeIsInstanceOf('arguments', arguments, Arguments)
	assert.parameterTypeIsInstanceOf('sysrootPath', sysrootPath, Path)
	
	sysrootPath:assertIsFolderPath('sysrootPath')
	sysrootPath:assertIsEffectivelyAbsolute('sysrootPath')
	
	arguments:append(self.sysrootPathOption .. sysrootPath:toString(true))
end

-- Allows to remap standard names for gcc as they change by version, warn about obsolence, etc
function module:addCStandard(arguments, cStandard)
	assert.parameterTypeIsInstanceOf('arguments', arguments, Arguments)
	assert.parameterTypeIsInstanceOf('cStandard', cStandard, CStandard)
	
	arguments:append(self.standardOption .. cStandard.value)
end

function module:doNotPredefineSystemOrCompilerDriverMacros(arguments)
	assert.parameterTypeIsInstanceOf('arguments', arguments, Arguments)

	arguments:append(self.undefOption)
end

function module:undefinePreprocessorMacro(arguments, defineName)
	assert.parameterTypeIsInstanceOf('arguments', arguments, Arguments)
	assert.parameterTypeIsString('defineName', defineName)

	arguments:append(self.undefineOption .. defineName)
end

function module:definePreprocessorMacro(arguments, defineName, defineValue)
	assert.parameterTypeIsInstanceOf('arguments', arguments, Arguments)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsString('defineValue', defineValue)

	arguments:append(self.defineOption .. defineName .. '=' .. defineValue)
end

local function populateIncludePaths(includePaths, includePath)
	if includePaths[includePath] == nil then
		includePaths[includePath] = true
	end
end

assert.globalTypeIsFunction('ipairs', 'pairs')
function module:addSystemIncludePaths(arguments, dependenciesSystemIncludePaths, buildVariantSystemIncludePaths)
	assert.parameterTypeIsInstanceOf('arguments', arguments, Arguments)
	assert.parameterTypeIsTable('dependenciesSystemIncludePaths', dependenciesSystemIncludePaths)
	assert.parameterTypeIsTable('buildVariantSystemIncludePaths', buildVariantSystemIncludePaths)
	
	local systemIncludePaths = {}
	for _, systemIncludePath in ipairs(mergeFlags(self.systemIncludePaths, dependenciesSystemIncludePaths, buildVariantSystemIncludePaths)) do
		populateIncludePaths(systemIncludePaths, systemIncludePath)
	end
	
	for systemIncludePath, _ in pairs(systemIncludePaths) do
		arguments:append(self.systemIncludePathOption .. systemIncludePath)
	end	
end

assert.globalTypeIsFunction('pairs')
function module:addIncludePaths(arguments, sourceFilePaths)
	assert.parameterTypeIsInstanceOf('arguments', arguments, Arguments)
	assert.parameterTypeIsInstanceOf('sourceFilePaths', sourceFilePaths, FilePaths)
	
	local includePaths = {}
	for sourceFilePath in sourceFilePaths:iterate() do
		local stringPath = sourceFilePath:toString(true)
		populateIncludePaths(includePaths, stringPath)
	end
	for includePath, _ in pairs(includePaths) do
		arguments:append(self.includePathOption .. includePath)
	end	
end

assert.globalTypeIsFunction('ipairs')
function module:addLinkerFlags(arguments, dependenciesLinkerFlags, buildVariantLinkerFlags, otherLinkerFlags)
	assert.parameterTypeIsInstanceOf('arguments', arguments, Arguments)
	assert.parameterTypeIsTable('dependenciesLinkerFlags', dependenciesLinkerFlags)
	assert.parameterTypeIsTable('buildVariantLinkerFlags', buildVariantLinkerFlags)
	assert.parameterTypeIsTable('otherLinkerFlags', otherLinkerFlags)
	
	for _, linkerFlag in ipairs(mergeFlags(self.linkerFlags, dependenciesLinkerFlags, buildVariantLinkerFlags, otherLinkerFlags)) do
		arguments:append(linkerFlag)
	end
end

assert.globalTypeIsFunction('ipairs')
function module:addLinkedLibraries(arguments, dependenciesLinkedLibraries, buildVariantLinkedLibraries, otherLinkedLibraries)
	assert.parameterTypeIsInstanceOf('arguments', arguments, Arguments)
	assert.parameterTypeIsTable('dependenciesLinkedLibraries', dependenciesLinkedLibraries)
	assert.parameterTypeIsTable('buildVariantLinkedLibraries', buildVariantLinkedLibraries)
	assert.parameterTypeIsTable('otherLinkedLibraries', otherLinkedLibraries)
	
	for _, linkedLibrary in ipairs(mergeFlags(self.linkedLibraries, dependenciesLinkedLibraries, buildVariantLinkedLibraries, otherLinkedLibraries)) do
		arguments:append(self.linkedLibraryOption .. linkedLibrary)
	end
end

assert.globalTypeIsFunction('ipairs')
function module:unsetEnvironmentVariables(unsetEnvironmentVariableFunction)
	assert.parameterTypeIsFunctionOrCall('unsetEnvironmentVariableFunction', unsetEnvironmentVariableFunction)
	
	for _, environmentVariableName in ipairs(self.environmentVariablesToUnset) do
		unsetEnvironmentVariableFunction(environmentVariableName)
	end
end

assert.globalTypeIsFunction('pairs')
function module:exportEnvironmentVariables(exportEnvironmentVariableFunction, environmentVariableOverrides)
	assert.parameterTypeIsFunctionOrCall('exportEnvironmentVariableFunction', exportEnvironmentVariableFunction)
	assert.parameterTypeIsTable('environmentVariableOverrides', environmentVariableOverrides)
	
	for environmentVariableName, environmentVariableValue in pairs(self.environmentVariablesToExport) do
		local actualValue
		actualValue = environmentVariableOverrides[environmentVariableName]
		if actualValue == nil then
			actualValue = environmentVariableValue
		end
		exportEnvironmentVariableFunction(environmentVariableName, actualValue)
	end
end

local gcc4X_environmentVariablesToUnset = {'LANG', 'LC_CTYPE', 'LC_MESSAGES', 'LC_ALL', 'TMPDIR', 'GCC_COMPARE_DEBUG', 'GCC_EXEC_PREFIX', 'COMPILER_PATH', 'LIBRARY_PATH', 'LANG', 'CPATH', 'C_INCLUDE_PATH', 'CPLUS_INCLUDE_PATH', 'OBJC_INCLUDE_PATH', 'DEPENDENCIES_OUTPUT', 'SUNPRO_DEPENDENCIES'}
local gcc4X_environmentVariablesToExport = {LANG = 'C', LC_CTYPE = 'C', LC_MESSAGES = 'C', LC_ALL = 'C'}

-- 'native' and 'generic' are dangerous, in that they change in gcc releases
-- '-pipe' might not work on some systems (?weird windows ones?)
CompilerDriver.static.gcc49_systemNativeHostX86_64 =     CompilerDriver:new(CompilerMetadata['gcc 4.9'],     {'-pipe', '-mtune=native', '-march=native'}, {'-E'}, {'-S'}, {'-c'}, {'-x', 'none'}, gcc4X_environmentVariablesToUnset, gcc4X_environmentVariablesToExport)
CompilerDriver.static.gccxx49_systemNativeHostX86_64 =   CompilerDriver:new(CompilerMetadata['g++ 4.9'],     {'-pipe', '-mtune=native', '-march=native'}, {'-E'}, {'-S'}, {'-c'}, {'-x', 'none'}, gcc4X_environmentVariablesToUnset, gcc4X_environmentVariablesToExport)
CompilerDriver.static.clang34_systemNativeHostX86_64 =   CompilerDriver:new(CompilerMetadata['clang 3.4'],   {'-pipe', '-mtune=native', '-march=native'}, {'-E'}, {'-S'}, {'-c'}, {'-x', 'none'}, gcc4X_environmentVariablesToUnset, gcc4X_environmentVariablesToExport)
CompilerDriver.static.clangxx34_systemNativeHostX86_64 = CompilerDriver:new(CompilerMetadata['clang++ 3.4'], {'-pipe', '-mtune=native', '-march=native'}, {'-E'}, {'-S'}, {'-c'}, {'-x', 'none'}, gcc4X_environmentVariablesToUnset, gcc4X_environmentVariablesToExport)
