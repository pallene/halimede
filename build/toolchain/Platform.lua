--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Platform = moduleclass('Platform')

local halimede = require('halimede')
local assert = halimede.assert
local addFileExtensionToFileNames = requireSibling('Toolchain').addFileExtensionToFileNames
local tabelize = require('halimede.table.tabelize').tabelize
local AbstractShellScriptExecutor = require('halimede.io.shellScript.shellScriptExecutors.AbstractShellScriptExecutor')
local GnuTuple = requireSibling('GnuTuple')
local CompilerDriver = requireSibling('CompilerDriver')
local toolchainPathStrategies = requireSibling('toolchainPathStrategies')


function Platform:initialize(name, toolchainPathStrategy, shellScriptExecutor, gnuTuple, objectExtension, executableExtension, staticLibraryPrefix, staticLibraryExtension, dynamicLibraryPrefix, dynamicLibraryExtension, cCompilerDriver, cPlusPlusCompilerDriver)
	assert.parameterTypeIsString(name)
	assert.parameterTypeIsFunctionOrCall(toolchainPathStrategy)
	assert.parameterTypeIsInstanceOf(shellScriptExecutor, AbstractShellScriptExecutor)
	assert.parameterTypeIsString(objectExtension)
	assert.parameterTypeIsString(executableExtension)
	assert.parameterTypeIsString(staticLibraryPrefix)
	assert.parameterTypeIsString(staticLibraryExtension)
	assert.parameterTypeIsString(dynamicLibraryPrefix)
	assert.parameterTypeIsString(dynamicLibraryExtension)
	assert.parameterTypeIsInstanceOf(gnuTuple, GnuTuple)
	assert.parameterTypeIsInstanceOf(cCompilerDriver, CompilerDriver)
	assert.parameterTypeIsInstanceOf(cPlusPlusCompilerDriver, CompilerDriver)
	
	self.name = name
	self.toolchainPathStrategy = toolchainPathStrategy
	self.shellScriptExecutor = shellScriptExecutor
	self.objectExtension = objectExtension
	self.executableExtension = executableExtension
	self.staticLibraryPrefix = staticLibraryPrefix
	self.staticLibraryExtension = staticLibraryExtension
	self.dynamicLibraryPrefix = dynamicLibraryPrefix
	self.dynamicLibraryExtension = dynamicLibraryExtension
	self.gnuTuple = gnuTuple
	self.cCompilerDriver = cCompilerDriver
	self.cPlusPlusCompilerDriver = cPlusPlusCompilerDriver
		
	Platform.static[name] = self
end

function module:_newConfigHDefines()
	return self.gnuTuple:newConfigHDefines()
end

assert.globalTypeIsFunction('ipairs')
function module:createConfigHDefines(platformConfigHDefinesFunctions)
	assert.parameterTypeIsTable(platformConfigHDefinesFunctions)
	
	local configHDefines = self:_newConfigHDefines()
	for _, platformConfigHDefinesFunction in ipairs(platformConfigHDefinesFunctions) do
		platformConfigHDefinesFunction(configHDefines, self)
	end
	return configHDefines
end

function module:toolchainPath(toolchainPaths, pathName)
	return toolchainPaths[pathName](self.toolchainPathStrategy, self.shellScriptExecutor.shellLanguage)
end

assert.globalTypeIsFunction('ipairs')
function module:toObjects(...)
	local shellLanguage = self.shellScriptExecutor.shellLanguage
	
	local result = tabelize()
	for _, pathString in ipairs(...) do
		local relativeFilePath = shellLanguage:parsePath(pathString, true)
		result:insert(relativeFilePath:appendFileExtension(self.objectExtension))
	end
	return result
end

assert.globalTypeIsFunction('ipairs')
function module:toObjectsWithoutPaths(...)
	local shellLanguage = self.shellScriptExecutor.shellLanguage
	
	local result = tabelize()
	for _, pathString in ipairs(...) do
		local relativeFilePath = shellLanguage:parsePath(pathString, true)
		result:insert(relativeFilePath:appendFileExtension(self.objectExtension):finalPathElementName())
	end
	return result
end

-- MinGW is a toolchain, but 32-bit
-- MSYS is a colleciton of Unix utilities but with a toolchain for their creation
-- See here for a Mac OS X / MinGW-w64 toolchain script for inspiration: https://gist.github.com/Drakulix/9881160
-- DJGPP is legacy but active; v2.05 Released in Nov 2015

--[[
Unix utilities on Windows:-
	MSYS (no functional FIFO)
	GnuWin32 (no functional FIFO)
	UnxUtils
	UWIN (Korn)

Unix POSIX platforms:-
	Cygwin
	Interix (Dead) (Last released for Windows 8) (Uses GCC 3.3, includes a GCC frontend compatible wrapper for MSVC)
	MKS Toolkit
]]--

local commandIsOnPathAndShellIsAvaiableToUseIt = require('halimede.io.commandIsAvailable').commandIsOnPathAndShellIsAvaiableToUseIt
local macOsXShellScriptExecutor
if commandIsOnPathAndShellIsAvaiableToUseIt('brew') then
	macOsXShellScriptExecutor = require('halimede.io.shellScript.shellScriptExecutors.MacOsXHomebrewShellScriptExecutor').MacOsXHomebrewShellScriptExecutor
else
	macOsXShellScriptExecutor = require('halimede.io.shellScript.shellScriptExecutors.OrdinaryShellScriptExecutor').Posix
end

Platform:new(
	'Mac OS X Mavericks GCC / G++ 4.9 Homebrew',
	ToolchainPathStrategies.pathVersioned,
	macOsXShellScriptExecutor,
	'.o',
	'', -- eg .exe on Windows
	'lib',
	'.a',
	'lib',
	'.dylib',
	GnuTuple['x86_64-apple-darwin13.4.0'],
	CompilerDriver.gcc49_systemNativeHostX86_64,
	CompilerDriver.gccxx49_systemNativeHostX86_64
)

Platform:new(
	'Mac OS X Yosemite GCC / G++ 4.9 Homebrew',
	ToolchainPathStrategies.pathVersioned,
	macOsXShellScriptExecutor,
	'.o',
	'',
	'lib',
	'.a',
	'lib',
	'.dylib'
	GnuTuple['x86_64-apple-darwin14'],
	CompilerDriver.gcc49_systemNativeHostX86_64,
	CompilerDriver.gccxx49_systemNativeHostX86_64
)
