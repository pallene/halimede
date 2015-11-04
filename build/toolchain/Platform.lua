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


function Platform:initialize(name, shellScriptExecutor, gnuTuple, objectExtension, executableExtension, staticLibraryPrefix, staticLibraryExtension, dynamicLibraryPrefix, dynamicLibraryExtension, cCompilerDriver, cPlusPlusCompilerDriver)
	assert.parameterTypeIsString(name)
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
	
	local shellLanguage = self.shellScriptExecutor.shellLanguage
	self.shellLanguage = shellLanguage
	self.folderSeparator = shellLanguage.folderSeparator
	self.pathSeparator = shellLanguage.pathSeparator
	self.lowerCasedName = shellLanguage.lowerCasedName
	self.titleCasedName = shellLanguage.titleCasedName
	
	Platform.static[name] = self
end

XXXX: shellScript

-- Arguments are things like shellScript, etc...
-- Doesn't work for the CompilerDriver actions like ExecutableLinkCompilerDriverShellScriptAction with unsetEnvironmentVariableActionCreator, exportEnvironmentVariableActionCreator
-- We could either have Windows and Posix variants (which is an ok idea), or have the class object declare 'actions' it needs populated
-- Still unpleasant, as have to construct with arguments the client doesn't know
assert.globalTableHasChieldFieldOfTypeFunction('string', 'format')
function Platform:newAction(actionName, namespace, ...)
	assert.parameterTypeIsString(actionName)
	
	local actionNamespace
	if namespace == nil then
		actionNamespace = 'halimide.build.shellScriptActions'
	else
		assert.parameterTypeIsString(namespace)
		actionNamespace = namespace
	end
	
	-- Try to see if there's a Posix, Cmd, etc variant
	local potentialShellVariantModuleName = ('%s.%s.%s%sShellScriptAction'):format(actionNamespace, self.lowerCasedName, actionName, self.titleCasedName)
	local ok, resultOrErrorMessage = pcall(require, potentialShellVariantModuleName)
	if ok then
		local ShellScriptActionClass = resultOrErrorMessage
		return ShellScriptActionClass:new(...)
	end
	
	local potentialModuleName = ('%s.%sShellScriptAction'):format(actionNamespace, actionName)
	return require(potentialModuleName):new(...)
end

function Platform:concatenateToPath(...)
	return table.concat({...}, self.folderSeparator)
end

function Platform:concatenateToPaths(...)
	return table.concat({...}, self.pathSeparator)
end

function Platform:toObjects(...)
	return addFileExtensionToFileNames(self.objectExtension, ...)
end

function Platform:newConfigHDefines()
	return self.gnuTuple:newConfigHDefines()
end

function Platform:toObjectsWithoutPaths(...)
	local result = tabelize()
	for _, pathPrefixedFileName in ipairs(self:toObjects(...)) do
		result:insert(halimede.basename(pathPrefixedFileName))
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
	macOsXShellScriptExecutor,
	'/',
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
	macOsXShellScriptExecutor,
	'/',
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
