--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception
local OperatingSystem = halimede.build.toolchain.operatingSystems.OperatingSystem


local PosixOperatingSystem = halimede.moduleclass('PosixOperatingSystem', OperatingSystem)

function module:initialize(normalisedUnameOperatingSystemName, description, hasBsdUserspace, architectures)
	OperatingSystem.initialize(self, normalisedUnameOperatingSystemName, description, architectures, false, true, hasBsdUserspace)
end


-- DEAD: alpha, i386, parisc64, hppa64, parisc, hppa, vax
-- TODO: arm*, arc, cris, crisv32, arceb, aarch64_be, e2k, frv, hexagon, i*86, ia64, k1om, m32r, mips, mips64, openrisc, or32, padre, ppc, ppc64, ppc64le, ppcle, s390, s390x, sh64, sh, sparc, sparc64, tile, xtensa, cris, crisv32, avr32
-- TODO: Sort out arm, mips, powerpc sub-archs (little or big endian, floating point modes). Likewise consider adopting the same for i386, i486, i586, i686. Also need to deal with processor 'features' (eg all the various SIMD variants in x86_64 land)
-- To test Ubuntu Linux on POWER8 Little Endian: https://www.siteox.com/cart.php?gid=22
local Linux = PosixOperatingSystem:new('Linux', 'Linux', false, {aarch64 = 'ARM64',
	x86_64 = 'x86_64'
})

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'split')
function Linux:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText)
	-- Very messy; many distros version their kernels in all sorts of ways
	-- Fundamentally, though, most stick to Major.Minor.Revision-Patch, although after Patch it can be either '.' or '-'

	local versionData = rSwitchText:split('.')
	local major = versionData[1]
	local length = #versionData
	local minor = length > 1 and versionData[2] or '0'
	local revision
	if length < 3 then
		revision = '0'
	else
		revision = (versionData[3]:split('-'))[1]
	end
	
	return self:_createVersion(major, minor, revision, nil)
end

PosixOperatingSystem.static.Linux = Linux

-- To test Solaris on SPARC64, use https://www.siteox.com/cart.php?gid=19 ($20 / day)
local Solaris = PosixOperatingSystem:new('SunOS', 'Solaris', false, {sun4u = 'SPARC64', i86pc = 'x86_64'})

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'split')
function Solaris:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText)
	-- 5.8  => Solaris 8
	-- 5.9  => Solaris 9
	-- 5.10 => Solaris 10
	-- 5.11 => Solaris 11
	local versionData = rSwitchText:split('.')
	local major = versionData[1]
	local minor = versionData[2] or '0'
	local revision = '0'
	
	return createVersion(major, minor, revision, nil)
end


local DebianFreeBSD = PosixOperatingSystem:new('GNU/kFreeBSD',  'Debian on FreeBSD Kernel', false, {})

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'split')
function DebianFreeBSD:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText)
	-- eg 9.0.2-amd64
	local versionData = rSwitchText:split('.')
	local major = versionData[1]
	local length = #versionData
	local minor = versionData[2] or '0'
	local revision
	if length < 3 then
		revision = '0'
	else
		revision = versionData[3]:split('-')
	end
	
	return self:_createVersion(major, minor, revision, nil)
end


-- There are also ARM, m68k (Atari Falcon) and PowerPC (?ppc) highly experimental ports
local Haiku = PosixOperatingSystem:new('Haiku', 'Haiku',  false, {'BePC' = 'IA-32', x86_64 = 'x86_64'})

-- Version since 2012 is alwasy '1' (as of Jan 2016); we ought to look at using vSwitchText
function Haiku:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText)
	return self:_createVersion(rSwitchText, '0', '0', nil)
end
