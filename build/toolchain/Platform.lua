--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Platform = moduleclass('Platform')

local halimede = require('halimede')
local assert = halimede.assert
local GnuTuple = requireSibling('GnuTuple')
local CompilerDriver = requireSibling('CompilerDriver')
local addFileExtensionToFileNames = requireSibling('Toolchain').addFileExtensionToFileNames
local tabelize = require('halimede.table.tabelize').tabelize
local ShellLanguage = require('halimede.io.ShellLanguage')


function Platform:initialize(name, shellLanguage, folderSeparator, newLine, gnuTuple, objectExtension, executableExtension, staticLibraryPrefix, staticLibraryExtension, dynamicLibraryPrefix, dynamicLibraryExtension, cCompilerDriver, cPlusPlusCompilerDriver)
	assert.parameterTypeIsString(name)
	assert.parameterTypeIsTable(shellLanguage)
	assert.parameterTypeIsString(folderSeparator)
	assert.parameterTypeIsString(newLine)
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
	self.folderSeparator = folderSeparator
	self.shellLanguage = shellLanguage
	self.objectExtension = objectExtension
	self.executableExtension = executableExtension
	self.staticLibraryPrefix = staticLibraryPrefix
	self.staticLibraryExtension = staticLibraryExtension
	self.dynamicLibraryPrefix = dynamicLibraryPrefix
	self.dynamicLibraryExtension = dynamicLibraryExtension
	self.gnuTuple = gnuTuple
	self.cCompilerDriver = cCompilerDriver
	self.cPlusPlusCompilerDriver = cPlusPlusCompilerDriver
	
	self.newLine = shellLanguage.newline
	self.pathSeparator = shellLanguage.pathSeparator
	
	Platform.static[name] = self
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

Platform:new(
	'Mac OS X Mavericks GCC / G++ 4.9 Homebrew',
	ShellLanguage.POSIX,
	'/',
	'\n',
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
	ShellLanguage.POSIX,
	'/',
	'\n',
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
