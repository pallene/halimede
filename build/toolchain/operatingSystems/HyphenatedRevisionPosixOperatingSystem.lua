--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local PosixOperatingSystem = halimede.build.toolchain.operatingSystems.PosixOperatingSystem


local HyphenatedRevisionPosixOperatingSystem = halimede.moduleclass('HyphenatedRevisionPosixOperatingSystem', PosixOperatingSystem)

function module:initialize(normalisedUnameOperatingSystemName, description, hasBsdUserspace, architectures)
	PosixOperatingSystem.initialize(self, normalisedUnameOperatingSystemName, description, hasBsdUserspace, architectures)
end

-- eg 6.1-RELEASE-p15
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'find', 'sub', 'split')
function module:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText)
	local index = rSwitchText:find('-')
	local versionNumbers = rSwitchText:sub(1, index - 1):split('.')
	local revisionNumbers = rSwitchText:sub(index + 1):split('-')
	
	local minor
	if #versionNumbers > 1 then
		minor = versionNumbers[2]
	else
		minor = '0'
	end
	
	local revision
	if #revisionNumbers > 1 then
		revision = revisionNumbers[2]
	else
		revision = '0'
	end
	
	return self:_createVersion(versionNumbers[1], minor, revision, nil)
end


HyphenatedRevisionPosixOperatingSystem:new('DragonFly', 'DragonFly BSD', true, {x86_64 = 'x86_64'})

HyphenatedRevisionPosixOperatingSystem:new('FreeBSD',   'FreeBSD',     , true, {
	amd64 = 'x86_64',
	i386 = 'IA-32',
	ia64 = 'IA-64',
	powerpc = 'PowerPC',
	powerpc64 = 'PowerPC64',
	sparc64 = 'SPARC64',
	armv6 = 'ARM',
	aarch64 = 'ARM64'
})
