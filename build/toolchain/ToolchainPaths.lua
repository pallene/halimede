--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


moduleclass('ToolchainPaths')
local AbsolutePath = require('halimede.io.paths.AbsolutePath')
local RelativePath = require('halimede.io.paths.RelativePath')

local halimede = require('halimede')
local assert = halimede.assert
local exception = require('halimede.exception')

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

local toolchainPathStrategies = {
	
	-- The default, eg returns /usr/bin if prefixPath == '/' and folderName == 'bin'
	pathConstant = function(prefixPath, versionRelativePath, ...)
		local folderPath = RelativePath:new(...)
		local relativePath = folderPath
		local absolutePath = prefixPath:appendRelativePathOf(relativePath)
		
		return absolutePath, relativePath
	end
	
	-- eg returns '/opt/package/version/dependencies/bin' if prefixPath == '/opt'
	pathVersioned = function(prefixPath, versionRelativePath, ...)
		local folderPath = RelativePath:new(...)
		local relativePath = folderPath:appendRelativePathOf(versionRelativePath)
		local absolutePath = prefixPath:appendRelativePathOf(relativePath)
		
		return absolutePath, relativePath
	end
	
	-- eg returns '/bin/package/version/dependencies/bin' if prefixPath == '/' and folderName == 'bin'
	pathInsidePackage = function(prefixPath, versionRelativePath, ...)
		local folderPath = RelativePath:new(...)
		local relativePath = versionRelativePath:appendRelativePathOf(folderPath)
		local absolutePath = prefixPath:appendRelativePathOf(relativePath)
		
		return absolutePath, relativePath
	end
}




function module:initialize(strategy, sysrootPath, versionRelativePath, prefixPath, execPrefixPath, libPrefixPath)
	assert.parameterTypeIsFunctionOrCall(strategy)
	assert.parameterTypeIsInstanceOf(sysrootPath, AbsolutePath)
	assert.parameterTypeIsInstanceOf(versionRelativePath, RelativePath)
	assert.parameterTypeIsInstanceOf(prefixPath, AbsolutePath)
	assert.parameterTypeIsInstanceOf(execPrefixPath, AbsolutePath)

	self.sysrootPath = sysrootPath
	self.versionRelativePath = versionRelativePath
	self.prefixPath = prefixPath
	self.execPrefixPath = execPrefixPath
	if libPrefixPath == nil then
		self.libPrefixPath = prefixPath
	else
		assert.parameterTypeIsInstanceOf(libPrefixPath, AbsolutePath)
		self.libPrefixPath = libPrefixPath
	end
	
	-- User Executables (bindir)
	self.packageBinAbsolutePath, self.packageBinRelativePath = strategy(execPrefixPath, versionRelativePath, 'bin')
	
	-- System Administrator Executables (sbindir)
	self.packageSbinAbsolutePath, self.packageSbinRelativePath = strategy(execPrefixPath, versionRelativePath, 'sbin')
	
	-- Program Executables (libexecdir)
	self.packageLibexecAbsolutePath, self.packageLibexecRelativePath = strategy(execPrefixPath, versionRelativePath, 'libexec')
	
	-- TODO: Needs to go into a per-machine location so it can be modified / mounted independently of build
	-- TODO: Probably some sort of overlay approach using rsync (ie replacements for default config)
	-- Read-only single-machine data (sysconfdir)
	self.packageEtcAbsolutePath, self.packageEtcRelativePath = strategy(prefixPath, versionRelativePath, 'etc')
	
	-- Modifiable architecture-independent data (sharedstatedir)  -- ? is this similar to /srv ?
	self.packageComAbsolutePath, self.packageComRelativePath = strategy(prefixPath, versionRelativePath, 'com')
	
	-- TODO: Needs a different strategy
	-- TODO: Probably needs to go into a per-machine location so can be independently mountained (we will want to retain state)
	-- TODO: We may not want to version this
	-- Modifiable single-machine data (localstatedir)
	self.packageVarAbsolutePath, self.packageVarRelativePath = strategy(prefixPath, versionRelativePath, 'var')
	
	-- TODO: Consider splitting out .a from .so during installs
	-- Object code libraries (libdir)  (can contain both static .a and dynamic .so libraries as well as pkgconfig .pc cruft; the former is only needed at compile-time)
	self.packageLibAbsolutePath, self.packageLibRelativePath = strategy(libPrefixPath, versionRelativePath, 'lib')
	
	-- C header files (includedir)
	self.packageIncludeAbsolutePath, self.packageIncludeRelativePath = strategy(prefixPath, versionRelativePath, 'include')
	
	-- C header files for non-gcc (oldincludedir)
	self.packageOldIncludeAbsolutePath, self.packageOldIncludeRelativePath = strategy(prefixPath, versionRelativePath, 'oldinclude')  -- GNU configure default is /usr/include
	
	-- Read-only archictecture-independent data root (datarootdir)
	self.packageShareAbsolutePath, self.packageShareRelativePath = strategy(prefixPath, versionRelativePath, 'share')
	
	-- Read-only idiosyncratic read-only architecture-independent data (datadir)
	self.packageDataAbsolutePath, self.packageDataRelativePath = strategy(prefixPath, versionRelativePath, 'share', 'data') -- GNU configure default is == datarootdir
	
	-- info documentation (infodir)
	self.packageInfoAbsolutePath, self.packageInfoRelativePath = strategy(prefixPath, versionRelativePath, 'share', 'info')
	
	-- locale-dependent data (localedir)
	self.packageManAbsolutePath, self.packageManRelativePath = strategy(prefixPath, versionRelativePath, 'share', 'locale')
	
	-- man documentation (mandir)
	self.packageManAbsolutePath, self.packageManRelativePath = strategy(prefixPath, versionRelativePath, 'share', 'man')
	
	-- documentation root (docdir)
	self.packageDocAbsolutePath, self.packageDocRelativePath = strategy(prefixPath, versionRelativePath, 'share', 'doc')
	
    -- html documentation (htmldir)
	self.packageHtmlAbsolutePath, self.packageHtmlRelativePath = strategy(prefixPath, versionRelativePath, 'share', 'doc', 'html')
	
    -- dvi documentation (dvidir)
	self.packageDviAbsolutePath, self.packageDviRelativePath = strategy(prefixPath, versionRelativePath, 'share', 'doc', 'dvi')
	
    -- pdf documentation (pdfdir)
	self.packagePdfAbsolutePath, self.packagePdfRelativePath = strategy(prefixPath, versionRelativePath, 'share', 'doc', 'pdf')
    
	-- ps documentation (psdir)
	self.packagePsAbsolutePath, self.packagePsRelativePath = strategy(prefixPath, versionRelativePath, 'share', 'doc', 'ps')
	
end

