--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception
local UnixOnWindowsOperatingSystem = halimede.build.toolchain.operatingSystems.UnixOnWindowsOperatingSystem


local PrefixedUnixOnWindowsOperatingSystem = halimede.moduleclass('PrefixedUnixOnWindowsOperatingSystem', UnixOnWindowsOperatingSystem)

function module:initialize(normalisedUnameOperatingSystemName, description, prefix, architectures)
	assert.parameterTypeIsString('prefix', prefix)
	
	UnixOnWindowsOperatingSystem.initialize(self, normalisedUnameOperatingSystemName, description, architectures)
	
	self.prefix = prefix
end

function module:_registerUname(legacy, startsWith, exactlyMatches)
	if startsWith[self.prefix] ~= nil then
		exception.throw("Already registered prefix '%s'", self.prefix)
	end
	startsWith[self.prefix] = self
end


-- TODO: Untested - at this point in time, I can't figure out how to create binaries from https://github.com/att/uwin
-- TODO: Architectures are incomplete
local Uwin = PrefixedUnixOnWindowsOperatingSystem:new('UWIN', 'AT&T UWIN', 'UWIN-', {
	['i686-64'] = 'x86_64'
})

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'split')
function Uwin:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText)
	local windowsVersionData = rSwitchText:split('.')
	local windowsMajor = windowsVersionData[1]
	local windowsMinor = #windowsVersionData > 1 and windowsVersionData[2] or '0'
	local windowsRevision = '0'
	
	-- YYYY-MM-DD
	local versionData = vSwitchText:split('.')
	local major = versionData[1]
	local minor = versionData[2]
	local revision = versionData[3]
	
	return self:_createVersion(windowsMajor, windowsMinor, windowsRevision, self:_createVersion(major, minor, revision, nil))
end


local prefix = 'Server 4.0 '
local GnuWin32 = PrefixedUnixOnWindowsOperatingSystem:new('windows32', 'GnuWin32', prefix, {
	[prefix .. 'i686-pc'] = 'IA-32'
})

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'sub', 'split')
function GnuWin32:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText)
	local versionData = rSwitchText:sub(#prefix + 1):split('.')

	-- We can not obtain windows version; -v is '6001'
	return self:_createVersion('0', '0', '0', self:_createVersion(versionData[1], versionData[2] or '0', versionData[3] or '0', nil))
end
