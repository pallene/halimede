--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--




-- Might want to give a toolchain object
function compile(hostCompilerDriver, crossCompilerDriver, standard)

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
	'remote-${REMOTE}', -- TODO:Varies on build-variant
	concatenateToPath('glob', 'fnmatch'),
	concatenateToPath('glob', 'glob'),
	-- TODO:alloca support may be needed (all modern platforms have this)
	-- TODO:Windows and VMS
}


return {
	dependencies = {
		--lua = '5.1'  => We resolve this to an identifier. For a more complex dep, it could by luarocks-2.4-lua-5.2 or luarocks-2.4-lua-5.1
		--             => We use two sorts of versioning: compatible and incompatible, eg lua 5.2.3 and Lua 5.2.4 are considered the same, because we use a symlink to 5.2. This was if we WANT to be specific (eg tie to Lua 5.2.4, say, we can)
		--             => It also lets us have build variants (eg debug or LuaJIT with different compatibility flags)
	}
	compilationUnits = {  -- The idea of a compilation unit is to make more effective LTO
		{
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
