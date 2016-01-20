--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local PosixOperatingSystem = halimede.build.toolchain.operatingSystems.PosixOperatingSystem


local DotRevisionPosixOperatingSystem = halimede.moduleclass('DotRevisionPosixOperatingSystem', PosixOperatingSystem)

function module:initialize(normalisedUnameOperatingSystemName, description, hasBsdUserspace, architectures)
	PosixOperatingSystem.initialize(self, normalisedUnameOperatingSystemName, description, hasBsdUserspace, architectures)
end

-- eg 6.1.5
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'split')
function module:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText)
	-- NetBSD: 6.1.5 or 7.0 or 7.0.RC3
	-- OpenBSD: 5.6
	-- Darwin: 14.5.0
	local versionData = rSwitchText:split('.')
	local major = versionData[1]
	local minor = versionData[2] or '0'
	local revision = versionData[3] or '0'
	
	return self:_createVersion(major, minor, revision, nil)
end

-- TODO: Support all NetBSD architectures
DotRevisionPosixOperatingSystem:new('NetBSD',  'NetBSD',   true, {amd64 = 'x86_64'})

DotRevisionPosixOperatingSystem:new('OpenBSD', 'OpenBSD',  true, {amd64 = 'x86_64'})

-- TODO: Support iPhone, etc ARM and ARM64 based devices
DotRevisionPosixOperatingSystem:new('Darwin',  'Mac OS X', true, {x86_64 = 'x86_64'})

DotRevisionPosixOperatingSystem:new('Minix',   'MINIX 3',  true, {i386 = 'IA-32'})
