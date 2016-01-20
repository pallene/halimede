--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception
local OperatingSystem = halimede.build.toolchain.operatingSystems.OperatingSystem


halimede.moduleclass('LegacyOperatingSystem', OperatingSystem)

function module:initialize(normalisedUnameOperatingSystemName, description)
	OperatingSystem.initialize(self, normalisedUnameOperatingSystemName, description, {}, false, false, false)
end

function module:_registerUname(legacy, startsWith, exactlyMatches)
	if legacy[self.normalisedUnameOperatingSystemName] ~= nil then
		exception.throw("Already registered legacy '%s'", self.normalisedUnameOperatingSystemName)
	end
	legacy[self.normalisedUnameOperatingSystemName] = self
end

function module:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText)
	exception.throw("Do not try to extract versioning data for a legacy operating system such as '%s'", self.normalisedUnameOperatingSystemName)
end

LegacyOperatingSystem:new('sn5176', 'Cray UNICOS')
LegacyOperatingSystem:new('IRIX', 'Silicon Graphics IRIX (32 bit)')
LegacyOperatingSystem:new('IRIX64', 'Silicon Graphics IRIX (64 bit)')
LegacyOperatingSystem:new('ReliantUNIX-Y', 'ReliantUNIX-Y')
LegacyOperatingSystem:new('SINIX-Y', 'SINIX-Y')
LegacyOperatingSystem:new('OSF1', 'Digital / Compaq / HP Tru64')
LegacyOperatingSystem:new('ULTRIX', 'ULTRIX')
LegacyOperatingSystem:new('SCO_SV', 'SCO OpenServer / System V')
LegacyOperatingSystem:new('UnixWare', 'SCO UnixWare')
LegacyOperatingSystem:new('IS/WB', 'SYS$UNIX:SH on OpenVMS on VAX emulator')
