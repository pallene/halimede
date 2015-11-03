--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local function configHDefinesNew(configHDefines, packageOrganisation, packageName, packageVersion, chosenBuildVariantNames)
	
	local version = packageVersion .. '-' .. table.concat(chosenBuildVariantNames, '-')
	
	configHDefines:PACKAGE(packageName)
	configHDefines:PACKAGE_BUGREPORT('bug-' .. packageName .. '@gnu.org')
	configHDefines:PACKAGE_NAME(packageOrganisation .. ' ' .. packageName)
	configHDefines:PACKAGE_STRING(packageOrganisation .. ' ' .. packageName .. ' ' .. version)
	configHDefines:PACKAGE_TARNAME(packageName)
	configHDefines:PACKAGE_URL('http://www.gnu.org/software/' .. packageName .. '/')
	configHDefines:PACKAGE_VERSION(version)
	configHDefines:VERSION(version)

	-- Embed GNU Guile support
	function configHDefines:HAVE_GUILE(enable)
		self:_boolean('HAVE_GUILE', enable)
	end

	-- Define to 1 to enable job server support in GNU make.
	function configHDefines:MAKE_JOBSERVER(enable)
		self:_boolean('MAKE_JOBSERVER', enable)
	end

	-- Enable only if HAVE_DECL_DLOPEN, HAVE_DECL_DLSYM, HAVE_DECL_DLERROR
	-- Define to 1 to enable 'load' support in GNU make.
	function configHDefines:MAKE_LOAD(enable)
		self:_boolean('MAKE_LOAD', enable)
	end
	
	-- Define to 1 to enable symbolic link timestamp checking.
	function configHDefines:MAKE_SYMLINKS(enable)
		self:_boolean('MAKE_SYMLINKS', enable)
	end
	
	-- Define to 1 if your system requires backslashes or drive specs in pathnames
	function configHDefines:HAVE_DOS_PATHS(enable)
		self:_boolean('HAVE_DOS_PATHS', enable)
	end

	-- Use platform specific coding
	function configHDefines:WINDOWS32(enable)
		self:_boolean('WINDOWS32', enable)
	end

	-- Use case insensitive file names
	function configHDefines:HAVE_CASE_INSENSITIVE_FS(enable)
		self:_boolean('HAVE_CASE_INSENSITIVE_FS', enable)
	end

	-- Use high resolution file timestamps if nonzero.
	function configHDefines:FILE_TIMESTAMP_HI_RES(enable)
		self:_boolean('FILE_TIMESTAMP_HI_RES', enable)
	end

	-- Define to 1 if you have a standard gettimeofday function
	function configHDefines:HAVE_GETTIMEOFDAY(enable)
		self:_boolean('HAVE_GETTIMEOFDAY', enable)
	end

	-- Define to 1 if struct nlist.n_name is a pointer rather than an array.
	function configHDefines:NLIST_STRUCT(enable)
		self:_boolean('NLIST_STRUCT', enable)
	end

	-- Mandatory
	-- Define to 1 if you have the declaration of `dlerror', and to 0 if you don't.
	function configHDefines:HAVE_DECL_DLERROR(enable)
		self:_oneOrZero('HAVE_DECL_DLERROR', enable)
	end

	-- Mandatory
	-- Define to 1 if you have the declaration of `dlopen', and to 0 if you don't.
	function configHDefines:HAVE_DECL_DLOPEN(enable)
		self:_oneOrZero('HAVE_DECL_DLOPEN', enable)
	end

	-- Mandatory
	-- Define to 1 if you have the declaration of `dlsym', and to 0 if you don't.
	function configHDefines:HAVE_DECL_DLSYM(enable)
		self:_oneOrZero('HAVE_DECL_DLSYM', enable)
	end

	-- Mandatory
	-- Define to 1 if you have the declaration of `sys_siglist', and to 0 if you don't.
	function configHDefines:HAVE_DECL_SYS_SIGLIST(enable)
		self:_oneOrZero('HAVE_DECL_SYS_SIGLIST', enable)
	end

	-- Mandatory
	-- Define to 1 if you have the declaration of `_sys_siglist', and to 0 if you don't.
	function configHDefines:HAVE_DECL__SYS_SIGLIST(enable)
		self:_oneOrZero('HAVE_DECL__SYS_SIGLIST', enable)
	end

	-- Mandatory
	-- Define to 1 if you have the declaration of `__sys_siglist', and to 0 if you don't.
	function configHDefines:HAVE_DECL___SYS_SIGLIST(enable)
		self:_oneOrZero('HAVE_DECL___SYS_SIGLIST', enable)
	end

	-- Define to 1 if you have the 'union wait' type in <sys/wait.h>.
	function configHDefines:HAVE_UNION_WAIT(enable)
		self:_boolean('HAVE_UNION_WAIT', enable)
	end

	-- Define to 1 if <signal.h> defines the SA_RESTART constant.
	function configHDefines:HAVE_SA_RESTART(enable)
		self:_boolean('HAVE_SA_RESTART', enable)
	end

	-- Mandatory
	-- Define to the name of the SCCS 'get' command.
	function configHDefines:SCCS_GET(command)
		self:_quotedNonEmptyString('SCCS_GET', command)
	end

	-- Define to 1 if the SCCS 'get' command understands the '-G<file>' option.
	function configHDefines:SCCS_GET_MINUS_G(enable)
		self:_boolean('SCCS_GET_MINUS_G', enable)
	end
	
	-- Define to `int' if <sys/types.h> does not define.
	function configHDefines:pid_t(enable)
		self:_defineIfMissing('pid_t', enable, 'int')
	end

	-- Define to `unsigned int' if <sys/types.h> does not define.
	function configHDefines:size_t(enable)
		self:_defineIfMissing('size_t', enable, 'unsigned int')
	end

	-- NOTE: There is a better test than this in autoconf AC_TYPE_UINTMAX_T
	-- Define uintmax_t if not defined in <stdint.h> or <inttypes.h>.
	function configHDefines:uintmax_t(enable)
		self:_defineIfMissing('uintmax_t', enable, 'unsigned long long')
	end

	-- Build host information.
	function ConfigHDefines:MAKE_HOST(stringToQuote)
		self:_quotedNotEmptyString(stringToQuote)
	end
end

local function configHDefinesDefault(configHDefines, platform)
	-- Obsolete
	configH:SCCS_GET('get')  -- Harcoded search for /usr/sccs/get, oh my... probably ought to set this to 'false'; used in default.c as one of the default make variables. Make really is disgusting.
end

-- Exceptions: Pure Windows, MinGW / MSYS, possibly older stuff like UWIN, DJGPP, Interix, etc
local function configHDefinesIsPosix(configHDefines, platform)
	-- Not-Make-specific, but depend on toolchain (apart from _GNU_SOURCE); given how common these are, we could just enable them regardless
	configH:_ALL_SOURCE(true)
	configH:_GNU_SOURCE(true)
	configH:_POSIX_PTHREAD_SEMANTICS(true)
	configH:_TANDEM_SOURCE(true)
	configH:__EXTENSIONS__(true)
	
	configH:HAVE_DECL_DLERROR(true)
	configH:HAVE_DECL_DLOPEN(true)
	configH:HAVE_DECL_DLSYM(true)
	configH:MAKE_LOAD(true) -- HAVE_DECL_DLERROR && HAVE_DECL_DLOPEN && HAVE_DECL_DLSYM
	configH:MAKE_SYMLINKS(true)  -- HAVE_LSTAT and HAVE_READLINK; not true for MinGW / MSYS
	configH:FILE_TIMESTAMP_HI_RES(true)
	configH:MAKE_JOBSERVER(true) -- OS/2 or MingGW or HAVE_PIPE && HAVE_SIGACTION && HAVE_SA_RESTART && ?WAIT_NOHANG?
end

local function configHDefinesIsBsd(configHDefines, platform)
end

local function configHDefinesIsMacOsX(configHDefines, platform)
	-- Make-specific, but depend on toolchain
	configH:HAVE_GETTIMEOFDAY(true)
	configH:HAVE_DECL_SYS_SIGLIST(true)
	configH:HAVE_SA_RESTART(true)
end

-- This is a stub
local function configHDefinesIsWindows(configHDefines, platform)
	configH:WINDOWS32(true)
	configH:FILE_TIMESTAMP_HI_RES(false)
end

local function compile(compileUnitActions, buildEnvironment, buildVariant, configHDefines)
		
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
		buildEnvironment.buildToolchain.platform:concatenateToPath('glob', 'fnmatch'),
		buildEnvironment.buildToolchain.platform:concatenateToPath('glob', 'glob'),
	}
	
	
	configH:MAKE_HOST(crossPlatform.gnuTuple.triplet)
	compileUnitActions:writeConfigH()
	
	
	local crossCompile = true
	local compilerDriverFlags = {}
	local standard = CStandard.gnu90
	local cEncoding = LegacyCandCPlusPlusStringLiteralEncoding.C
	local preprocessorFlags = {}
	local defines = Defines:new(false)
	defines:_quotedNonEmptyString('LOCALEDIR', buildEnvironment.crossToolchain.platform:concatenateToPath(sysrootPath, 'lib'))
	defines:_quotedNonEmptyString('LIBDIR', buildEnvironment.crossToolchain.platform:concatenateToPath(sysrootPath, 'include'))
	defines:_quotedNonEmptyString('INCLUDEDIR', buildEnvironment.crossToolchain.platform:concatenateToPath(sysrootPath, 'share', 'local'))
	defines:_boolean('HAVE_CONFIG_H', true)
	local sources = buildEnvironment:toCFiles(baseFileNames)
	compileUnitActions:actionCompilerDriverCPreprocessCompileAndAssemble(crossCompile, compilerDriverFlags, standard, cEncoding, preprocessorFlags, defines, sources)
	
	
	-- Do we want to name stuff, rather than use command line switches?
	local linkerFlags = {
		'-rdynamic'  -- or -Wl,--export-dynamic
	}
	local objects = buildEnvironment.crossToolchain.platform:toObjectsWithoutPaths(baseFileNames)
	local linkedLibraries = {}
	local baseName = 'make'
	compileUnitActions:actionCompilerDriverLinkCExecutable(crossCompile, compilerDriverFlags, linkerFlags, objects, linkedLibraries, baseName)
end

--[[
We name builds after the build variant, I suspect

* So:-
	make:default:4.1
	make:customs-debug-dmalloc:4.1

* We always sort in name order

* However we need to also capture dependency names, too, ideally in the folder structure
   * Can get very long; use either a hash of the dependencies, sorted, or a git hash
   * Also need to cope with common dependencies (eg progB depends on libA depends on Lua; progB also depends on Lua; so progB should use same Lua version as libA)

Other variants include version of each dependency and version of toolchain

]]--

return {
	dependencies = {
		--lua = '5.1'  => We resolve this to an identifier. For a more complex dep, it could by luarocks-2.4-lua-5.2 or luarocks-2.4-lua-5.1
		--             => We use two sorts of versioning: compatible and incompatible, eg lua 5.2.3 and Lua 5.2.4 are considered the same, because we use a symlink to 5.2. This was if we WANT to be specific (eg tie to Lua 5.2.4, say, we can)
		--             => It also lets us have build variants (eg debug or LuaJIT with different compatibility flags)
	},
	package = {
		organisation = 'GNU'
		name = 'make',
		version = '4.1'
	},
	buildVariants = {
		-- Must be defined
		default = {
			conflicts = {
				'customs',
				'debug'
			},
			arguments = {
				REMOTE = 'stub'
			},
			-- Consider converting this to more abstract concepts, eg 'no-debugging', 'optimise for speed'
			compilerDriverFlags = {
				'-g0',
				'-O2'
			},
			-- Need to support PIE and PIC and toolchain hardening
			-- Consider adding compiler driver specific extensions, eg
			compilerDriverFlagsToolchain = {
				['gcc-4.8'] = {
					'-O3'
				},
				-- or by toolchain name
				['MacOsXMavericks'] = {
				},
				-- or by long name
				['gcc-4.9-x86_64-linux-musl'] = {
				},
				-- or by linux or bsd distro and version (or sub-version, for some BSDs) (quite a good choice)
				-- doesn't work for gentoo, arch, MirBSD and other rolling releases
				['linux-ubuntu-trusty'] = {
				},
				-- TODO: Problems arise when we have multiple compilation units
			}
		},
		-- Ought to be defined
		debug = {
			conflicts = {
			},
			compilerDriverFlags = {
				'-g'
			},
		},
		caseInsensitiveFileSystem = {
			conflicts = {},
			defines = {},
			configHDefines = {
				HAVE_CASE_INSENSITIVE_FS = true
			}
		},
		customs = {
			conflicts = {
				'default'
			},
			arguments = {
				REMOTE = 'cstms',
			},
			-- Affects CPPFLAGS
			includePaths = {'-Ixxx/include/customs'},
			libraryPaths = {'-Lxxx/lib'},
			libs = {'-lcustoms'}
		},
		dmalloc = {
			requires = {
				'debug'
			}
			conflicts = {
			},
			compilerDriverFlags = {
			},
			configHDefines = {
				WITH_DMALLOC = true
			},
			-- this is an example, by the way
			notSupportedToolchains = {
				-- Need quite complex matching rules, to cope with versions, etc
				['gcc-4.9-x86_64-linux-musl']
			},
			libraryPaths = {'-Lwherever-dmalloc-is'},
			libs = {'-ldmalloc'}
		},
		-- Uses pkg-config --cflags etc
		guile = {
			compilerDriverFlags = {
				-- ?
			},
			configHDefines = {
				HAVE_GUILE = true
			},
			libraryPaths = {'-Lwherever-guile-is'},
			libs = {'-lguile'}
		}	
	},
	configH = {
		new = configHDefinesNew,
		default = configHDefinesDefault,
		platforms = {
			isPosix = configHDefinesIsPosix,
			isBsd = configHDefinesIsBsd,
			isMacOsX = configHDefinesIsMacOsX
		}
	},
	compilationUnits = {
		compile
	}	
}
