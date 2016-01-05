--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
--[[

Some non-configure based installations (eg Lua and Shellfire) can only use relative paths for things like libdir. They can probably use '..' but will need patching
	-- For shellfire applications, though, there isn't really any need to install
- Homebrew installs to say /usr/local/Cellar/make/4.1, then creates helpful symlinks from /usr/local (the sysroot)
	- We could do something similar, but with a file listing which version is the 'default' (this can be done using a pattern match, eg 4.1-customs/dep-hashes might be matched by 4.*-*/*; multiple matches result in 'longest' file name winning. Not good for RC1 releases, perhaps, but means dot-releases and debug builds take priority)
- We might like to explore not having lib, bin, etc inside the package folder, so we can split out a noexec filesystem (and potentially also optional docs, headers, etc)
	- In essence, only /bin needs to be executable
	- We could hardlink into an /opt/bin, say, then delete the original /opt/package/version/bin
		- This works for all applications bar those that do relative discovery of their libraries / files (which is quite rare, but is what shellfire does and is what Lua does)
	- We could have subfolders under /opt/bin, eg /opt/bin/package/version/bin - that prevents collision
	- There are a very small number of version-resistant programs that need to be in well-known locations
		- /usr/bin/env [versioning almost inconsequential, as it never needs to change]
		- /bin/sh & /usr/bin/sh [a common assumption] [versioning almost inconsequential now if using dash or ash; slight issue if using busybox sh; big issue if using bash in POSIX mode]
		- /bin/bash [a common assumption]; versioning breaks lots of things
		- Lua (5.1 vs 5.2 vs 5.3)
		- Python (2.7 vs 3)
	- There are also limitations on how complex we can make PATH
		- Some scripts reset PATH (not unreasonably)
		- So follow the hombrew approach
		- We can also install binaries with a version-suffix
	- So we need a 'default' version of every program
	- Each package can be given a range of 100 group ids to use (or it could use extended groups)
		- Programs can belong to one of these groups


sysrootPath			eg /  or  /opt/readonly
perRecipeVersionRelativePathElements	eg package/version-variants/dependencies such as make/4.1-custom/hash
prefixPath			eg /opt/readonly  (for share, var, etc)
execPrefixPath		eg /opt/executable  (for bin, sbin and libexec [and potentially lib]); also for any block or character devices (will be mounted nosuid)
libPrefixPath		defaults to prefixPath; exists because it is debateable whether libraries should go under prefixPath or execPrefixPath (GNU ./configure's preference, but this makes having a readonly /usr/lib, say, impossible. Traditionally .so libs could be executable but in practice never are used this way)
Note that it is still possible to run scripts from a filesystem mounted noexec
]]--

local Path = halimede.io.paths.Path
local ShellLanguage = halimede.io.shellScript.ShellLanguage
local exception = halimede.exception


halimede.moduleclass('PlatformPaths')

module.static.validatePath = function(path, name, mustBe)
	path:assertIsFolderPath(name)

	if path.pathRelativity[mustBe] == false then
		exception.throw("%s '%s' must be %s", name, path, mustBe)
	end
end
local validatePath = module.validatePath

function module:initialize(perRecipeVersioningStrategy, sysrootPath, readonlyPrefixPath, execPrefixPath, libPrefixPath)
	assert.parameterTypeIsFunctionOrCall('perRecipeVersioningStrategy', perRecipeVersioningStrategy)
	assert.parameterTypeIsInstanceOf('sysrootPath', sysrootPath, Path)
	assert.parameterTypeIsInstanceOf('readonlyPrefixPath', readonlyPrefixPath, Path)

	validatePath(sysrootPath, 'sysrootPath', 'isEffectivelyAbsolute')
	validatePath(readonlyPrefixPath, 'readonlyPrefixPath', 'isEffectivelyAbsolute')

	self.perRecipeVersioningStrategy = perRecipeVersioningStrategy
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

function module:_path(prefixPath, perRecipeVersionRelativePathElements, ...)
	assert.parameterTypeIsInstanceOf('prefixPath', prefixPath, Path)
	assert.parameterTypeIsTable('perRecipeVersionRelativePathElements', perRecipeVersionRelativePathElements)

	local folderRelativePathElements = {...}
	return self.perRecipeVersioningStrategy(prefixPath, folderRelativePathElements, perRecipeVersionRelativePathElements)
end

function module:_readonlyPrefixPath(perRecipeVersionRelativePathElements, ...)
	return self:_path(self.readonlyPrefixPath, perRecipeVersionRelativePathElements, ...)
end

function module:_execPrefixPath(perRecipeVersionRelativePathElements, ...)
	return self:_path(self.execPrefixPath, perRecipeVersionRelativePathElements, ...)
end

function module:_libPrefixPath(perRecipeVersionRelativePathElements, ...)
	return self:_path(self.libPrefixPath, perRecipeVersionRelativePathElements, ...)
end

function module:sysroot()
	return self.sysrootPath
end

-- User Executables (bindir)
function module:bin(perRecipeVersionRelativePathElements)
	return self:_execPrefixPath(perRecipeVersionRelativePathElements, 'bin')
end

-- System Administrator Executables (sbindir)
function module:sbin(perRecipeVersionRelativePathElements)
	return self:_execPrefixPath(perRecipeVersionRelativePathElements, 'sbin')
end

-- Program Executables (libexecdir)
function module:libexec(perRecipeVersionRelativePathElements)
	return self:_execPrefixPath(perRecipeVersionRelativePathElements, 'libexec')
end

-- TODO: Needs to go into a per-machine location so it can be modified / mounted independently of build
-- TODO: Probably some sort of overlay approach using rsync (ie replacements for default config)
-- Read-only single-machine data (sysconfdir)
function module:etc(perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(perRecipeVersionRelativePathElements, 'etc')
end

-- Modifiable architecture-independent data (sharedstatedir)
function module:com(perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(perRecipeVersionRelativePathElements, 'com')
end

-- TODO: Probably needs to go into a per-machine location so can be independently mountained (we will want to retain state)
-- TODO: We may not want to self.version this
-- Modifiable single-machine data (localstatedir)
function module:var(perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(perRecipeVersionRelativePathElements, 'var')
end

-- TODO: Consider splitting out .a from .so during installs
-- Object code libraries (libdir)  (can contain both static .a and dynamic .so libraries as well as pkgconfig .pc cruft; the former is only needed at compile-time)
function module:lib(perRecipeVersionRelativePathElements)
	return self:_libPrefixPath(perRecipeVersionRelativePathElements, 'lib')
end

-- C header files (includedir)
function module:include(perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(perRecipeVersionRelativePathElements, 'include')
end

-- C header files for non-gcc (oldincludedir)
function module:oldinclude(perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(perRecipeVersionRelativePathElements, 'oldinclude')  -- GNU configure default is /usr/include
end

-- Read-only archictecture-independent data root (datarootdir)
function module:share(perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(perRecipeVersionRelativePathElements, 'share')
end

-- Read-only idiosyncratic read-only architecture-independent data (datadir)
function module:data(perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(perRecipeVersionRelativePathElements, 'share', 'data')  -- GNU configure default is == datarootdir
end

-- info documentation (infodir)
function module:info(perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(perRecipeVersionRelativePathElements, 'share', 'info')
end

-- locale-dependent data (localedir)
function module:locale(perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(perRecipeVersionRelativePathElements, 'share', 'locale')
end

-- man documentation (mandir)
function module:man(perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(perRecipeVersionRelativePathElements, 'share', 'man')
end

-- documentation root (docdir)
function module:doc(perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(perRecipeVersionRelativePathElements, 'share', 'doc')
end

-- html documentation (htmldir)
function module:html(perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(perRecipeVersionRelativePathElements, 'share', 'doc', 'html')
end

-- dvi documentation (dvidir)
function module:dvi(perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(perRecipeVersionRelativePathElements, 'share', 'doc', 'dvi')
end

-- pdf documentation (pdfdir)
function module:pdf(perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(perRecipeVersionRelativePathElements, 'share', 'doc', 'pdf')
end

-- ps documentation (psdir)
function module:ps(perRecipeVersionRelativePathElements)
	return self:_readonlyPrefixPath(perRecipeVersionRelativePathElements, 'share', 'doc', 'ps')
end
