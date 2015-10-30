--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('middleclass')
local AbsolutePath = require('halimede.io.paths.AbsolutePath')
local toTemporaryFileAllContentsInTextModeAndUse = require('halimede.io.temporaryWrite').toTemporaryFileAllContentsInTextModeAndUse
local execute = require('halimede.io.execute')
local executeExpectingSuccess = execute.executeExpectingSuccess
local noRedirection = execute.noRedirection
local commandIsOnPathAndShellIsAvaiableToUseIt = require('halimede.io.commandIsAvailable').commandIsOnPathAndShellIsAvaiableToUseIt


local AbstractCompileUnitActions = class('AbstractCompileUnitActions')

function AbstractCompileUnitActions:initialize(shellLanguage, sourcePath, sysrootPath, toolchain)
	assert.parameterTypeIsTable(shellLanguage)
	assert.parameterTypeIsInstanceOf(sourcePath, AbsolutePath)
	assert.parameterTypeIsInstanceOf(sysrootPath, AbsolutePath)
	assert.parameterTypeIsTable(toolchain)
	
	self.shellLanguage = shellLanguage
	self.sourcePath = sourcePath
	self.sysrootPath = sysrootPath
	self.toolchain = toolchain
	self.compilerDriver = toolchain.compilerDriver
	
	self.script = tabelize({})
	self._initialBuildScript()
	self.actionChangeDirectory(sourcePath)
end

assert.globalTypeIsFunction('ipairs')
function AbstractCompileUnitActions:appendLinesToBuildScript(...)
	local lines = {...}
	for _, line in ipairs(lines) do
		self.script:insert(line)
		self.script:insert(self.shellLanguage.shellScriptFileExtensionIncludingLeadingPeriod)
	end
end

function AbstractCompileUnitActions:appendCommandLineToBuildScript(...)
	self.script:insert(self.shellLanguage.toShellCommandLine(...))
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

function AbstractCompileUnitActions:_prepareCompilerDriver(crossCompile, compilerDriverFlags)
	
	-- The toolchain controls PATH, target, the need to unset GCC_EXEC_PREFIX, etc
	local arguments = tabelize({})
	
	local toolchain
	local compilerDriver
	if crossCompile then
		toolchain = self.crossCompileToolchain
	else
		-- Actually, this may end up being a bootstrap, etc
		toolchain = self.hostToolchain
	end
	addFlags(arguments, toolchain.compilerDriver)
	arguments:insert('--sysroot=' .. self.sysrootPath.path)
	
	return arguments
end

assert.globalTypeIsFunction('unpack', 'pairs', 'ipairs')
function AbstractCompileUnitActions:actionCompilerDriverPreprocessAndCompile(crossCompile, compilerDriverFlags, standard, preprocessorFlags, defines, undefines, doNotPredefineSystemOrCompilerDriverMacros, sources)
	assert.parameterTypeIsBoolean(crossCompile)
	assert.parameterTypeIsTable(compilerDriverFlags)
	assert.parameterTypeIsString(standard)
	assert.parameterTypeIsTable(preprocessorFlags)
	assert.parameterTypeIsTable(defines)
	assert.parameterTypeIsTable(undefines)
	assert.parameterTypeIsBoolean(doNotPredefineSystemOrCompilerDriverMacros)
	assert.parameterTypeIsTable(sources)
	
	local argments = self._prepareCompilerDriver(crossCompile, compilerDriverFlags)
	arguments:insert('-c')
	arguments:insert('-std=' .. standard)
	addFlags(arguments, preprocessorFlags)
	for defineName, defineValue in pairs(defines) do
		assert.parameterTypeIsString(defineName)
		
		if type(defineValue) == 'boolean' then
			if defineValue == false then
				exception.throw("The define '%s' can not be a boolean false", defineName)
			end
			-- Equivalent to defineValue=1
			arguments:insert('-D' .. defineName)
		else
			assert.parameterTypeIsString(defineValue)
			arguments:insert('-D' .. defineName .. '=' .. defineValue)
		end
	end
	for _, defineName in pairs(undefines) do
		assert.parameterTypeIsString(defineName)
		arguments:insert('-U' .. defineName)
	end
	if doNotPredefineSystemOrCompilerDriverMacros then
		arguments:insert('-undef')
	end
	addFlags(arguments, sources)
	
	self:actionUnsetEnvironmentVariable('GCC_EXEC_PREFIX')
	self:appendCommandLineToBuildScript(unpack(arguments))
end

-- Need to add '-L' switches; there's a horrible interaction between sysroot and what gets embedded in the dynamic linker... and RPATH
-- Additional LinkedLibraries is a bit of a mess
-- eg pthread, m => several libraries from one compilation unit (c lib on Linux)
assert.globalTypeIsFunction('unpack', 'pairs')
function AbstractCompileUnitActions:compilerDriverLinkExecutable(crossCompile, compilerDriverFlags, linkerFlags, objects, additionalLinkedLibraries, baseName)
	assert.parameterTypeIsBoolean(crossCompile)
	assert.parameterTypeIsTable(compilerDriverFlags)
	assert.parameterTypeIsTable(linkerFlags)
	assert.parameterTypeIsTable(objects)
	assert.parameterTypeIsTable(additionalLinkedLibraries)
	assert.parameterTypeIsString(baseName)
	
	local argments = self._prepareCompilerDriver(crossCompile, compilerDriverFlags)
	addFlags(arguments, linkerFlags)
	addFlags(arguments, objects)
	for _, linkedLibrary in ipairs(additionalLinkedLibraries) do
		arguments:insert('-l' .. linkedLibrary)
	end
	
	self:actionUnsetEnvironmentVariable('GCC_EXEC_PREFIX')
	self:appendCommandLineToBuildScript(unpack(arguments))
end

function AbstractCompileUnitActions:executeScript()
	self:appendLinesToBuildScript(self._finishBuildScript())
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
