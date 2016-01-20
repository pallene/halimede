--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local sibling = halimede.build.toolchain
local exception = halimede.exception
local AbstractShellScriptExecutor = halimede.io.shellScript.shellScriptExecutors.AbstractShellScriptExecutor
local GnuTuple = sibling.GnuTuple
local CompilerDriver = sibling.CompilerDriver
local AbstractStrip = halimede.build.shellScriptActions.strip.AbstractStrip
local MacOsXStrip = halimede.build.shellScriptActions.strip.MacOsXStrip


local Platform = halimede.moduleclass('Platform')

function Platform:initialize(name, useHomebrew, shellScriptExecutor, objectExtension, executableExtension, staticLibraryPrefix, staticLibraryExtension, dynamicLibraryPrefix, dynamicLibraryExtension, gnuTuple, cCompilerDriver, cPlusPlusCompilerDriver, strip)
	assert.parameterTypeIsString('name', name)
	assert.parameterTypeIsBoolean('useHomebrew', useHomebrew)
	assert.parameterTypeIsInstanceOf('shellScriptExecutor', shellScriptExecutor, AbstractShellScriptExecutor)
	assert.parameterTypeIsString('objectExtension', objectExtension)
	assert.parameterTypeIsStringOrNil('executableExtension', executableExtension)
	assert.parameterTypeIsString('staticLibraryPrefix', staticLibraryPrefix)
	assert.parameterTypeIsString('staticLibraryExtension', staticLibraryExtension)
	assert.parameterTypeIsString('dynamicLibraryPrefix', dynamicLibraryPrefix)
	assert.parameterTypeIsString('dynamicLibraryExtension', dynamicLibraryExtension)
	assert.parameterTypeIsInstanceOf('gnuTuple', gnuTuple, GnuTuple)
	assert.parameterTypeIsInstanceOf('cCompilerDriver', cCompilerDriver, CompilerDriver)
	assert.parameterTypeIsInstanceOf('cPlusPlusCompilerDriver', cPlusPlusCompilerDriver, CompilerDriver)
	assert.parameterTypeIsInstanceOfOrNil('strip', strip, AbstractStrip)

	if shellScriptExecutor.shellLanguage.pathStyle:isReservedPathElement(name) then
		exception.throw("The name 'name' contains a character that isn't permitted in a file name on this platform; the platform's name may be used in folder paths")
	end

	self.name = name
	self.useHomebrew = useHomebrew
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
	self.strip = strip

	self.shellLanguage = shellScriptExecutor.shellLanguage

	Platform.static[name] = self
end

-- Some of these things may already be known, some may not be...
-- sysrootPath is either 'compile time' (eg '/') or for-all-recipes (eg /some/output/location) or changes after initial bootstrapping
--   it is only needed at compile time for includes and linking (but may be encoded as RPATH if not careful)
-- I really feel the prefixes are for-all-recipes (ie should be )
function module:newPlatformPaths(perRecipeVersioningStrategy, sysrootPath, readonlyPrefixPath, execPrefixPath, libPrefixPath)
end

function module:_newConfigHDefines()
	return self.gnuTuple:newConfigHDefines()
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:createConfigHDefines(platformConfigHDefinesFunctions)
	assert.parameterTypeIsTable('platformConfigHDefinesFunctions', platformConfigHDefinesFunctions)

	local configHDefines = self:_newConfigHDefines()
	for _, platformConfigHDefinesFunction in ipairs(platformConfigHDefinesFunctions) do
		platformConfigHDefinesFunction(configHDefines, self)
	end
	return configHDefines
end

function module:toExecutableRelativeFilePath(filePath)
	filePath:assertIsFilePath('filePath')

	return filePath:appendFileExtension(self.executableExtension)
end

function module:objectRelativeFilePath(...)
	filePath:assertIsFilePath('filePath')

	return filePath:appendFileExtension(self.objectExtension)
end

function module:parentPaths(count)
	return self.shellLanguage:parentPaths(count)
end

function module:relativeFolderPath(...)
	return self.shellLanguage:relativeFolderPath(...)
end

function module:relativeFilePath(...)
	return self.shellLanguage:relativeFilePath(...)
end


-- We really ned a MacOSX / Linux check, too
--local shellLanguage = halimede.io.shellScript.ShellLanguage.default()
--local macOsXShellScriptExecutor
--if shellLanguage:commandIsOnPathAndShellIsAvailableToUseIt('brew') then
--	macOsXShellScriptExecutor = halimede.io.shellScript.shellScriptExecutors.MacOsXHomebrewShellScriptExecutor.MacOsXHomebrewShellScriptExecutor
--else
--	macOsXShellScriptExecutor =
--end

local shellScriptExecutor = halimede.io.shellScript.shellScriptExecutors.OrdinaryShellScriptExecutor.Posix
local macOsXStrip = MacOsXStrip:new()

Platform:new(
	'Mac OS X Yosemite GCC-Clang Homebrew',
	true,
	shellScriptExecutor,
	'o',
	nil,
	'lib',
	'a',
	'lib',
	'dylib',
	GnuTuple['x86_64-apple-darwin14.5.0'],
	CompilerDriver.gcc49_systemNativeHostX86_64,
	CompilerDriver.gccxx49_systemNativeHostX86_64,
	macOsXStrip
)

Platform:new(
	'Mac OS X Mavericks GCC-Clang Homebrew',
	true,
	shellScriptExecutor,
	'o',
	nil, -- eg exe on Windows
	'lib',
	'a',
	'lib',
	'dylib',
	GnuTuple['x86_64-apple-darwin13.4.0'],
	CompilerDriver.gcc49_systemNativeHostX86_64,
	CompilerDriver.gccxx49_systemNativeHostX86_64,
	macOsXStrip
)
