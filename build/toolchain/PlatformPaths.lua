--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local Path = halimede.io.paths.Path
local ShellPath = halimede.io.shellScript.ShellPath
local exception = halimede.exception
local AbstractPlatformPathStrategy = halimede.build.toolchain.platformPathStrategies.AbstractPlatformPathStrategy


halimede.moduleclass('PlatformPaths')

module.static.validatePath = function(path, name, mustBe)
	path:assertIsFolderPath(name)

	if path.pathRelativity[mustBe] == false then
		exception.throw("%s '%s' must be %s", name, path, mustBe)
	end
end
local validatePath = module.validatePath

function module:initialize(platformPathStrategy, sysrootPath, readonlyPrefixPath, execPrefixPath, libPrefixPath)
	assert.parameterTypeIsInstanceOf('platformPathStrategy', platformPathStrategy, AbstractPlatformPathStrategy)
	assert.parameterTypeIsInstanceOf('sysrootPath', sysrootPath, Path)
	assert.parameterTypeIsInstanceOf('readonlyPrefixPath', readonlyPrefixPath, Path)

	validatePath(sysrootPath, 'sysrootPath', 'isEffectivelyAbsolute')
	validatePath(readonlyPrefixPath, 'readonlyPrefixPath', 'isEffectivelyAbsolute')

	self.platformPathStrategy = platformPathStrategy
	self.sysrootPath = sysrootPath
	self.readonlyPrefixPath = readonlyPrefixPath

	if execPrefixPath == nil then
		self.execPrefixPath = readonlyPrefixPath
	else
		assert.parameterTypeIsInstanceOf('execPrefixPath', execPrefixPath, Path)
		validatePath(execPrefixPath, 'execPrefixPath', 'isEffectivelyAbsolute')
		self.execPrefixPath = execPrefixPath
	end

	if libPrefixPath == nil then
		self.libPrefixPath = readonlyPrefixPath
	else
		assert.parameterTypeIsInstanceOf('libPrefixPath', libPrefixPath, Path)
		validatePath(libPrefixPath, 'libPrefixPath', 'isEffectivelyAbsolute')
		self.libPrefixPath = libPrefixPath
	end
end

function module:destinationIsInstallation()
	return self.platformPathStrategy.destinationIsInstallation
end

function module:_path(prefixPath, destFolderShellPath, perRecipeVersionRelativePathElements, ...)
	assert.parameterTypeIsInstanceOf('prefixPath', prefixPath, Path)
	assert.parameterTypeIsInstanceOf('destFolderShellPath', destFolderShellPath, ShellPath)
	assert.parameterTypeIsTable('perRecipeVersionRelativePathElements', perRecipeVersionRelativePathElements)

	local folderRelativePathElements = {...}
	return self.platformPathStrategy:path(prefixPath, destFolderShellPath, folderRelativePathElements, perRecipeVersionRelativePathElements)
end

function module:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, ...)
	return self:_path(self.readonlyPrefixPath, destFolderShellPath, perRecipeVersionRelativePathElements, ...)
end

function module:_execPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, ...)
	return self:_path(self.execPrefixPath, destFolderShellPath, perRecipeVersionRelativePathElements, ...)
end

function module:_libPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, ...)
	return self:_path(self.libPrefixPath, destFolderShellPath, perRecipeVersionRelativePathElements, ...)
end

function module:sysroot()
	return self.sysrootPath
end

-- User Executables (bindir)
function module:bin(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_execPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'bin')
end

-- System Administrator Executables (sbindir)
function module:sbin(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_execPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'sbin')
end

-- Program Executables (libexecdir)
function module:libexec(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_execPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'libexec')
end

-- TODO: Needs to go into a per-machine location so it can be modified / mounted independently of build
-- TODO: Probably some sort of overlay approach using rsync (ie replacements for default config)
-- Read-only single-machine data (sysconfdir)
function module:etc(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'etc')
end

-- Modifiable architecture-independent data (sharedstatedir)
function module:com(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'com')
end

-- TODO: Probably needs to go into a per-machine location so can be independently mountained (we will want to retain state)
-- TODO: We may not want to self.version this
-- Modifiable single-machine data (localstatedir)
function module:var(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'var')
end

-- TODO: Consider splitting out .a from .so during installs
-- Object code libraries (libdir)  (can contain both static .a and dynamic .so libraries as well as pkgconfig .pc cruft; the former is only needed at compile-time)
function module:lib(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_libPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'lib')
end

-- C header files (includedir)
function module:include(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'include')
end

-- C header files for non-gcc (oldincludedir)
function module:oldinclude(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'oldinclude')  -- GNU configure default is /usr/include
end

-- Read-only archictecture-independent data root (datarootdir)
function module:share(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'share')
end

-- Read-only idiosyncratic read-only architecture-independent data (datadir)
function module:data(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'share', 'data')  -- GNU configure default is == datarootdir
end

-- info documentation (infodir)
function module:info(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'share', 'info')
end

-- locale-dependent data (localedir)
function module:locale(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'share', 'locale')
end

-- man documentation (mandir)
function module:man(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'share', 'man')
end

-- documentation root (docdir)
function module:doc(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'share', 'doc')
end

-- html documentation (htmldir)
function module:html(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'share', 'doc', 'html')
end

-- dvi documentation (dvidir)
function module:dvi(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'share', 'doc', 'dvi')
end

-- pdf documentation (pdfdir)
function module:pdf(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'share', 'doc', 'pdf')
end

-- ps documentation (psdir)
function module:ps(destFolderShellPath, perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(destFolderShellPath, perRecipeVersionRelativePathElements, 'share', 'doc', 'ps')
end
