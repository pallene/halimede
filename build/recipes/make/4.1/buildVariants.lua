--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


-- Typically affect dependencies (in this case, adds customs, guile and dmalloc)
return buildVariants = {
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
			-- TODO: Problems arise when mixing compilation units
		}
	},
	debug = {
		conflicts = {
			'dmalloc'
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
		conflicts = {
			'debug'
		},
		compilerDriverFlags = {
			'-g'
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
}
