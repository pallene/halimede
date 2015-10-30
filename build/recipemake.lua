--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


--[[
Actions in scope:-
	writeConfigH
	compilerDriverPreprocessAndCompile
	compilerDriverLinkExecutable

	Perhaps these should simply be functions that return a command line?
]]--

folderSeparator = '/'
pathSeparator = ':'
newLine = '\n'
objectExtension = '.o'
executableExtension = ''  -- Might be .exe on Windows

sysrootPath = '/opt'
destinationPath = '/opt/package/version'  -- Where version is, say, 2.0.4-lua-5.2 and package is luarocks


function quotedStringDefine(value)
	return '"' .. value .. '"'
end

function concatenateToPath(...)
	return table.concat({...}, folderSeparator)
end

function concatenateToPaths(...)
	return table.concat({...}, pathSeparator)
end

local function addFileExtension(extensionWithLeadingPeriod, ...)
	local asTable
	if select('#', ...) == 1 then
		if type(...) == 'table' then
			asTable = select(1, ...)
		else
			asTable = {...}
		end
	else
		asTable = {...}
	end
	
	local result = {}
	for _, basefilename in ipairs(asTable) do
		table.insert(result, basefilename .. extensionWithLeadingPeriod)
	end
	return result
end

function toCFiles(...)
	return addFileExtension('.c', ...)
end

function toObjects(...)
	return addFileExtension(objectExtension, ...)
end


-- Typically affect dependencies (in this case, adds customs and dmalloc)
local buildVariants = {
	default = {
		conflicts = {
			'customs',
			'debug'
		},
		arguments = {
			REMOTE = 'stub'
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

local basefilenames = {
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
	'remote-${REMOTE}', -- Varies depending on remote choice; requires expansion; see the lines starting   AC_SUBST([REMOTE]) REMOTE=stub  in configure.ac (affects flags, etc)
	concatenateToPath('glob', 'fnmatch'), -- Need if things missing; auto-add 'glob' as an include path
	concatenateToPath('glob', 'glob'), -- Need if things missing
	-- Also alloca support may be needed (all modern platforms have this)
}

return {
	dependencies = {
		--lua = '5.1'  => We resolve this to an identifier. For a more complex dep, it could by luarocks-2.4-lua-5.2 or luarocks-2.4-lua-5.1
		--             => We use two sorts of versioning: compatible and incompatible, eg lua 5.2.3 and Lua 5.2.4 are considered the same, because we use a symlink to 5.2. This was if we WANT to be specific (eg tie to Lua 5.2.4, say, we can)
		--             => It also lets us have build variants (eg debug or LuaJIT with different compatibility flags)
	}
	compilationUnits = {  -- The idea of a compilation unit is to make more effective LTO
		{
			staticLibraryPrefix = 'lib',
			staticLibraryExtension = '.a',
			dynamicLibraryPrefix = 'lib',
			dynamicLibraryExtension = '.so', -- might be .dylib on Mac OS X, but might not be if using Lua
			hostCompilation = false, -- True if not intended to be cross-compiled
			compilerDriverCFlags = {
				'-g0',
				'-O2'
			},
			standard = 'gnu90', -- -std=
			actions = {
				writeConfigH = {
				}
				compilerDriverPreprocessAndCompile = {  -- We need to have flags vary by gcc version (or apple fork), clang and potentially CParser and Tcc
					preprocessorFlags = {
						
					},
					defines = {
						LOCALEDIR = quotedStringDefine(concatenateToPath(sysrootPath, 'lib')),
						LIBDIR = quotedStringDefine(concatenateToPath(sysrootPath, 'include')),
						INCLUDEDIR = quotedStringDefine(concatenateToPath(sysrootPath, 'share/local'))
						HAVE_CONFIG_H = true,
					},
					sources = toCFiles(basefilenames)
				},
				-- Auto-add paths for -L from dependencies and from earlier compilation units?
				-- Is this static or dynamic ?
				compilerDriverLinkExecutable = {
					linkerFlags = {
						'-rdynamic'  -- or -Wl,--export-dynamic
					},
					objects = toObjects(basefilenames),
					-- eg pthread, m, etc => -lpthread, -lm, etc
					linkerAdditionalLibraries = {
					},
					basename = 'make'
				}
			}
		}
	}
}
