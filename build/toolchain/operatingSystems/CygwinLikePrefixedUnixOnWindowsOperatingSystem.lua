--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local PrefixedUnixOnWindowsOperatingSystem = halimede.build.toolchain.operatingSystems.PrefixedUnixOnWindowsOperatingSystem


local CygwinLikePrefixedUnixOnWindowsOperatingSystem = halimede.moduleclass('CygwinLikePrefixedUnixOnWindowsOperatingSystem', PrefixedUnixOnWindowsOperatingSystem)

function module:initialize(normalisedUnameOperatingSystemName, description)
	PrefixedUnixOnWindowsOperatingSystem.initialize(self, normalisedUnameOperatingSystemName, description, normalisedUnameOperatingSystemName .. '-', {
		i686 = 'IA-32',
		x86_64 = 'x86_64'
	})
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'match', 'split')
function module:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText)
	local windowsVersionData = (sSwitchText:split('-')[2]):split('.')
	local windowsMajor = windowsVersionData[1]
	local windowsMinor = #windowsVersionData > 1 and windowsVersionData[2] or '0'
	local windowsRevision = '0'
	
	-- eg  '2.3.1(0.291/5/3)'
	local major, minor, revision = rSwitchText:match('^([0-9]+).([0-9]+).([0-9]+)%(')
	return self:_createVersion(windowsMajor, windowsMinor, windowsRevision, self:_createVersion(major, minor, revision, nil))
end

CygwinLikePrefixedUnixOnWindowsOperatingSystem:new('CYGWIN_NT',  'Cygwin')

-- Impossible to distinguish MSYS from MSYS2 except by version numbers (MSYS2 is Cygwin 2.3.0+)
-- https://msys2.github.io/
-- MINGW32 installed by msys2
CygwinLikePrefixedUnixOnWindowsOperatingSystem:new('MSYS_NT',    'Minimal System 2')

-- x86_64-w64-mingw32
-- i686-w64-mingw32
CygwinLikePrefixedUnixOnWindowsOperatingSystem:new('MINGW32_NT', 'Minimal GNU for Windows (32-Bit)')

-- 64-bit mingw64 runs as i686 on 32-bit Windows; it's all bit confusing [this one is via MSYS2]
-- This is not the Non-GNU fork
CygwinLikePrefixedUnixOnWindowsOperatingSystem:new('MINGW64_NT', 'Minimal GNU for Windows (64-Bit)')
