--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--



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
versionRelativePath	eg package/version-variants/dependencies such as make/4.1-custom/hash
prefixPath			eg /opt/readonly  (for share, var, etc)
execPrefixPath		eg /opt/executable  (for bin, sbin and libexec [and potentially lib]); also for any block or character devices (will be mounted nosuid)
libPrefixPath		defaults to prefixPath; exists because it is debateable whether libraries should go under prefixPath or execPrefixPath (GNU ./configure's preference, but this makes having a readonly /usr/lib, say, impossible. Traditionally .so libs could be executable but in practice never are used this way)
Note that it is still possible to run scripts from a filesystem mounted noexec
]]--

moduleclass('ToolchainPaths')
local Path = require('halimede.io.paths.Path')

local halimede = require('halimede')
local exception = require('halimede.exception')


local function validatePath(path, name, mustBe)
	path:assertIsFolderPath(name)
	
	if path.pathStyle[mustBe] == false then
		exception.throw("%s '%s' must be %s", name, path, mustBe)
	end
end

function module:initialize(sysrootPath, versionRelativePath, prefixPath, execPrefixPath, libPrefixPath)
	assert.parameterTypeIsFunctionOrCall(toolchainPathStrategy, shellLanguage)
	assert.parameterTypeIsInstanceOf('sysrootPath', sysrootPath, Path)
	assert.parameterTypeIsInstanceOf('versionRelativePath', versionRelativePath, Path)
	assert.parameterTypeIsInstanceOf('prefixPath', prefixPath, Path)
	assert.parameterTypeIsInstanceOf('execPrefixPath', execPrefixPath, Path)
	
	validatePath(sysrootPath, 'sysrootPath', 'isEffectivelyAbsolute')
	validatePath(versionRelativePath, 'versionRelativePath', 'isRelative')
	validatePath(prefixPath, 'prefixPath', 'isEffectivelyAbsolute')
	validatePath(execPrefixPath, 'execPrefixPath', 'isEffectivelyAbsolute')
	
	self.sysrootPath = sysrootPath
	self.versionRelativePath = versionRelativePath
	self.prefixPath = prefixPath
	self.execPrefixPath = execPrefixPath
	if libPrefixPath == nil then
		self.libPrefixPath = prefixPath
	else
		assert.parameterTypeIsInstanceOf('libPrefixPath', libPrefixPath, Path)
		validatePath(libPrefixPath, 'libPrefixPath', 'isEffectivelyAbsolute')
		self.libPrefixPath = libPrefixPath
	end
end

function module:_path(toolchainPathStrategy, shellLanguage, path, ...)
	local folderRelativePath = shellLanguage:relativeFolderPath(...)
	return toolchainPathStrategy(path, self.versionRelativePath, folderRelativePath)
end

function module:_prefixPath(toolchainPathStrategy, shellLanguage, ...)
	return self:_path(toolchainPathStrategy, shellLanguage, self.prefixPath, ...)
end

function module:_execPrefixPath(toolchainPathStrategy, shellLanguage, ...)
	return self:_path(toolchainPathStrategy, shellLanguage, self.execPrefixPath, ...)
end

function module:_libPrefixPath(toolchainPathStrategy, shellLanguage, ...)
	return self:_path(toolchainPathStrategy, shellLanguage, self.libPrefixPath, ...)
end

-- User Executables (bindir)
function module:bin(toolchainPathStrategy, shellLanguage)
	return self:_execPrefixPath(toolchainPathStrategy, shellLanguage, 'bin')
end

-- System Administrator Executables (sbindir)
function module:sbin(toolchainPathStrategy, shellLanguage)
	return self:_execPrefixPath(toolchainPathStrategy, shellLanguage, 'sbin')
end

-- Program Executables (libexecdir)
function module:libexec(toolchainPathStrategy, shellLanguage)
	return self:_execPrefixPath(toolchainPathStrategy, shellLanguage, 'libexec')
end

-- TODO: Needs to go into a per-machine location so it can be modified / mounted independently of build
-- TODO: Probably some sort of overlay approach using rsync (ie replacements for default config)
-- Read-only single-machine data (sysconfdir)
function module:etc(toolchainPathStrategy, shellLanguage)
	return self:_prefixPath(toolchainPathStrategy, shellLanguage, 'etc')
end

-- Modifiable architecture-independent data (sharedstatedir)
function module:com(toolchainPathStrategy, shellLanguage)
	return self:_prefixPath(toolchainPathStrategy, shellLanguage, 'com')
end

-- TODO: Needs a different toolchainPathStrategy
-- TODO: Probably needs to go into a per-machine location so can be independently mountained (we will want to retain state)
-- TODO: We may not want to self.version this
-- Modifiable single-machine data (localstatedir)
function module:var(toolchainPathStrategy, shellLanguage)
	return self:_prefixPath(toolchainPathStrategy, shellLanguage, 'var')
end

-- TODO: Consider splitting out .a from .so during installs
-- Object code libraries (libdir)  (can contain both static .a and dynamic .so libraries as well as pkgconfig .pc cruft; the former is only needed at compile-time)
function module:lib(toolchainPathStrategy, shellLanguage)
	return self:_libPrefixPath(toolchainPathStrategy, shellLanguage, 'lib')
end

-- C header files (includedir)
function module:include(toolchainPathStrategy, shellLanguage)
	return self:_prefixPath(toolchainPathStrategy, shellLanguage, 'include')
end

-- C header files for non-gcc (oldincludedir)
function module:oldinclude(toolchainPathStrategy, shellLanguage)
	return self:_prefixPath(toolchainPathStrategy, shellLanguage, 'oldinclude')  -- GNU configure default is /usr/include
end

-- Read-only archictecture-independent data root (datarootdir)
function module:share(toolchainPathStrategy, shellLanguage)
	return self:_prefixPath(toolchainPathStrategy, shellLanguage, 'share')
end

-- Read-only idiosyncratic read-only architecture-independent data (datadir)
function module:data(toolchainPathStrategy, shellLanguage)
	return self:_prefixPath(toolchainPathStrategy, shellLanguage, 'share', 'data')  -- GNU configure default is == datarootdir
end

-- info documentation (infodir)
function module:info(toolchainPathStrategy, shellLanguage)
	return self:_prefixPath(toolchainPathStrategy, shellLanguage, 'share', 'info')
end

-- locale-dependent data (localedir)
function module:locale(toolchainPathStrategy, shellLanguage)
	return self:_prefixPath(toolchainPathStrategy, shellLanguage, 'share', 'locale')
end

-- man documentation (mandir)
function module:man(toolchainPathStrategy, shellLanguage)
	return self:_prefixPath(toolchainPathStrategy, shellLanguage, 'share', 'man')
end

-- documentation root (docdir)
function module:doc(toolchainPathStrategy, shellLanguage)
	return self:_prefixPath(toolchainPathStrategy, shellLanguage, 'share', 'doc')
end

-- html documentation (htmldir)
function module:html(toolchainPathStrategy, shellLanguage)
	return self:_prefixPath(toolchainPathStrategy, shellLanguage, 'share', 'doc', 'html')
end

-- dvi documentation (dvidir)
function module:dvi(toolchainPathStrategy, shellLanguage)
	return self:_prefixPath(toolchainPathStrategy, shellLanguage, 'share', 'doc', 'dvi')
end

-- pdf documentation (pdfdir)
function module:doc(toolchainPathStrategy, shellLanguage)
	return self:_prefixPath(toolchainPathStrategy, shellLanguage, 'share', 'doc', 'pdf')
end

-- ps documentation (psdir)
function module:ps(toolchainPathStrategy, shellLanguage)
	return self:_prefixPath(toolchainPathStrategy, shellLanguage, 'share', 'doc', 'ps')
end
