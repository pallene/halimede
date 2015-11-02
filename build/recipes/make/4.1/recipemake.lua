--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--




-- eg ...
local configH = self.toolchain.newConfigH()
function toolchain:newConfigH()
	return MacOsXMavericksConfigH:new()
end
--



local function newConfigH(configH, packageOrganisation, packageName, packageVersion)
	configH:PACKAGE(packageName)
	configH:PACKAGE_BUGREPORT('bug-' .. packageName .. '@gnu.org')
	configH:PACKAGE_NAME(packageOrganisation .. ' ' .. packageName)
	configH:PACKAGE_STRING(packageOrganisation .. ' ' .. packageName .. ' ' .. packageVersion)
	configH:PACKAGE_TARNAME(packageName)
	configH:PACKAGE_URL('http://www.gnu.org/software/' .. packageName .. '/')
	configH:PACKAGE_VERSION(packageVersion)
	configH:VERSION(packageVersion)

	-- Embed GNU Guile support
	function configH:HAVE_GUILE(enable)
		self:_boolean('HAVE_GUILE', enable)
	end

	-- Define to 1 to enable job server support in GNU make.
	function configH:MAKE_JOBSERVER(enable)
		self:_boolean('MAKE_JOBSERVER', enable)
	end

	-- Enable only if HAVE_DECL_DLOPEN, HAVE_DECL_DLSYM, HAVE_DECL_DLERROR
	-- Define to 1 to enable 'load' support in GNU make.
	function configH:MAKE_LOAD(enable)
		self:_boolean('MAKE_LOAD', enable)
	end
	
	-- Define to 1 to enable symbolic link timestamp checking.
	function configH:MAKE_SYMLINKS(enable)
		self:_boolean('MAKE_SYMLINKS', enable)
	end

	-- [detected by looking for *-*-mingw32 in $host in configure.ac]
	-- Define to 1 if your system requires backslashes or drive specs in pathnames
	function configH:HAVE_DOS_PATHS(enable)
		self:_boolean('HAVE_DOS_PATHS', enable)
	end

	-- Use platform specific coding
	function configH:WINDOWS32(enable)
		self:_boolean('WINDOWS32', enable)
	end

	-- Use case insensitive file names
	function configH:HAVE_CASE_INSENSITIVE_FS(enable)
		self:_boolean('HAVE_CASE_INSENSITIVE_FS', enable)
	end

	-- Use high resolution file timestamps if nonzero.
	function configH:FILE_TIMESTAMP_HI_RES(enable)
		self:_boolean('FILE_TIMESTAMP_HI_RES', enable)
	end

	-- Define to 1 if you have a standard gettimeofday function
	function configH:HAVE_GETTIMEOFDAY(enable)
		self:_boolean('HAVE_GETTIMEOFDAY', enable)
	end

	-- Define to 1 if struct nlist.n_name is a pointer rather than an array.
	function configH:NLIST_STRUCT(enable)
		self:_boolean('NLIST_STRUCT', enable)
	end

	-- Mandatory
	-- Define to 1 if you have the declaration of `dlerror', and to 0 if you don't.
	function configH:HAVE_DECL_DLERROR(enable)
		self:_oneOrZero('HAVE_DECL_DLERROR', enable)
	end

	-- Mandatory
	-- Define to 1 if you have the declaration of `dlopen', and to 0 if you don't.
	function configH:HAVE_DECL_DLOPEN(enable)
		self:_oneOrZero('HAVE_DECL_DLOPEN', enable)
	end

	-- Mandatory
	-- Define to 1 if you have the declaration of `dlsym', and to 0 if you don't.
	function configH:HAVE_DECL_DLSYM(enable)
		self:_oneOrZero('HAVE_DECL_DLSYM', enable)
	end

	-- Mandatory
	-- Define to 1 if you have the declaration of `sys_siglist', and to 0 if you don't.
	function configH:HAVE_DECL_SYS_SIGLIST(enable)
		self:_oneOrZero('HAVE_DECL_SYS_SIGLIST', enable)
	end

	-- Mandatory
	-- Define to 1 if you have the declaration of `_sys_siglist', and to 0 if you don't.
	function configH:HAVE_DECL__SYS_SIGLIST(enable)
		self:_oneOrZero('HAVE_DECL__SYS_SIGLIST', enable)
	end

	-- Mandatory
	-- Define to 1 if you have the declaration of `__sys_siglist', and to 0 if you don't.
	function configH:HAVE_DECL___SYS_SIGLIST(enable)
		self:_oneOrZero('HAVE_DECL___SYS_SIGLIST', enable)
	end

	-- Define to 1 if you have the 'union wait' type in <sys/wait.h>.
	function configH:HAVE_UNION_WAIT(enable)
		self:_boolean('HAVE_UNION_WAIT', enable)
	end

	-- Define to 1 if <signal.h> defines the SA_RESTART constant.
	function configH:HAVE_SA_RESTART(enable)
		self:_boolean('HAVE_SA_RESTART', enable)
	end

	-- Mandatory
	-- Define to the name of the SCCS 'get' command.
	function configH:SCCS_GET(command)
		self:_quotedNonEmptyString('SCCS_GET', command)
	end

	-- Define to 1 if the SCCS 'get' command understands the '-G<file>' option.
	function configH:SCCS_GET_MINUS_G(enable)
		self:_boolean('SCCS_GET_MINUS_G', enable)
	end
	
	-- Define to `int' if <sys/types.h> does not define.
	function configH:pid_t(enable)
		self:_defineIfMissing('pid_t', enable, 'int')
	end

	-- Define to `unsigned int' if <sys/types.h> does not define.
	function configH:size_t(enable)
		self:_defineIfMissing('size_t', enable, 'unsigned int')
	end

	-- NOTE: There is a better test than this in autoconf AC_TYPE_UINTMAX_T
	-- Define uintmax_t if not defined in <stdint.h> or <inttypes.h>.
	function configH:uintmax_t(enable)
		self:_defineIfMissing('uintmax_t', enable, 'unsigned long long')
	end

	-- Build host information.
	function ConfigHDefines:MAKE_HOST(stringToQuote)
		self:_quotedNotEmptyString(stringToQuote)
	end
end



local function compile(compileUnitActions, buildVariant, configH)
	
	-- Not-Make-specific, but depend on toolchain (apart from _GNU_SOURCE); given how common these are, we could just enable them regardless
	configH:_ALL_SOURCE(true)
	configH:_GNU_SOURCE(true)
	configH:_POSIX_PTHREAD_SEMANTICS(true)
	configH:_TANDEM_SOURCE(true)
	configH:__EXTENSIONS__(true)
	
	-- Make-specific, but depend on toolchain
	configH:FILE_TIMESTAMP_HI_RES(true)
	configH:HAVE_GETTIMEOFDAY(true)
	configH:HAVE_DECL_SYS_SIGLIST(true)
	configH:HAVE_SA_RESTART(true)
	configH:MAKE_JOBSERVER(true) -- OS/2 or MingGW or HAVE_PIPE && HAVE_SIGACTION && HAVE_SA_RESTART && ?WAIT_NOHANG?
	configH:HAVE_DECL_DLERROR(true)
	configH:HAVE_DECL_DLOPEN(true)
	configH:HAVE_DECL_DLSYM(true)
	configH:MAKE_LOAD(true) -- HAVE_DECL_DLERROR && HAVE_DECL_DLOPEN && HAVE_DECL_DLSYM
	configH:MAKE_SYMLINKS(true)  -- HAVE_LSTAT and HAVE_READLINK
	configH:MAKE_HOST("x86_64-apple-darwin13.4.0")  -- Toolchain target triple
	configH:SCCS_GET('get')  -- Harcoded search for /usr/sccs/get, oh my... probably ought to set this to 'false'; used in default.c as one of the default make variables. Make really is disgusting.
	
	
	compileUnitActions:writeConfigH()
	
	

	-- TODO:alloca support may be needed (all modern platforms have this)
	-- TODO:Windows and VMS have different file lists
	local baseFileNames = {
		'ar',
		'arscan',
		'commands',
		'default',
		'dir',
		'expand',
		'file',
		'function',
		'getopt',
		'getopt1',
		'guile',
		'implicit',
		'job',
		'load',
		'loadapi',
		'main',
		'misc',
		'output',
		'read',
		'remake',
		'rule',
		'signame',
		'strcache',
		'variable',
		'version',
		'vpath',
		'hash',
		'remote-' .. buildVariant.arguments.REMOTE,
		concatenateToPath('glob', 'fnmatch'),
		concatenateToPath('glob', 'glob'),
	}
	
	
	local crossCompile = true
	local compilerDriverFlags = {}
	local standard = CStandard.gnu90
	local cEncoding = LegacyCandCPlusPlusStringLiteralEncoding.C
	local preprocessorFlags = {}
	local defines = Defines:new(false)
	defines:_quotedNonEmptyString('LOCALEDIR', concatenateToPath(sysrootPath, 'lib'))
	defines:_quotedNonEmptyString('LIBDIR', concatenateToPath(sysrootPath, 'include'))
	defines:_quotedNonEmptyString('INCLUDEDIR', concatenateToPath(sysrootPath, 'share', 'local'))
	defines:_boolean('HAVE_CONFIG_H', true)
	local sources = toCFiles(baseFileNames)
	
	compileUnitActions:actionCompilerDriverCPreprocessCompileAndAssemble(crossCompile, compilerDriverFlags, standard, cEncoding, preprocessorFlags, defines, sources)
	
	
	-- Do we want to name stuff, rather than use command line switches?
	local linkerFlags = mergeFlags(buildVariant.linkerFlags, {
		'-rdynamic'  -- or -Wl,--export-dynamic
	}
	local objects = toObjectsWithoutPaths(baseFileNames)
	local additionalLinkedLibraries = {}
	local baseName = 'make'
	
	compileUnitActions:compilerDriverCLinkExecutable(crossCompile, compilerDriverFlags, linkerFlags, objects, additionalLinkedLibraries, baseName)
end

return {
	dependencies = {
		--lua = '5.1'  => We resolve this to an identifier. For a more complex dep, it could by luarocks-2.4-lua-5.2 or luarocks-2.4-lua-5.1
		--             => We use two sorts of versioning: compatible and incompatible, eg lua 5.2.3 and Lua 5.2.4 are considered the same, because we use a symlink to 5.2. This was if we WANT to be specific (eg tie to Lua 5.2.4, say, we can)
		--             => It also lets us have build variants (eg debug or LuaJIT with different compatibility flags)
	},
	package = {
		organisations = 'GNU'
		name = 'make',
		version = '4.1'
	},
	newConfigH = newConfigH,
	compilationUnits = {
		compile
	}	
}
