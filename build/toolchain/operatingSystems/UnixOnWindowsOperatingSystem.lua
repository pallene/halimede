--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local OperatingSystem = halimede.build.toolchain.operatingSystems.OperatingSystem


local UnixOnWindowsOperatingSystem = halimede.moduleclass('UnixOnWindowsOperatingSystem', OperatingSystem)

function module:initialize(normalisedUnameOperatingSystemName, description, architectures)
	OperatingSystem.initialize(self, normalisedUnameOperatingSystemName, description, architectures, true, true, false)
end

-- aka Windows Services for Unix, aka Subsystem for UNIX-based Applications, aka SUA
-- Last release is for Windows 2012
local Interix = UnixOnWindowsOperatingSystem:new('Interix', 'Microsoft POSIX', {
	x86 = 'IA-32',
	authenticamd = 'x86_64',
	genuineintel = 'x86_64',
	EM64T = 'x86_64',
	IA64 = 'IA-64'
})

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'split')
function Interix:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText)
	local windowsVersionData = rSwitchText:split('.')
	local windowsMajor = windowsVersionData[1]
	local windowsMinor = #windowsVersionData > 1 and windowsVersionData[2] or '0'
	local windowsRevision = '0'
	
	local versionData = vSwitchText:split('.')
	local major = versionData[1]
	local minor = versionData[2]
	local revision = versionData[3]
	
	return self:_createVersion(windowsMajor, windowsMinor, windowsRevision, self:_createVersion(major, minor, revision, nil))
end


-- This doesn't form a consistent environment (the user can download what they want). uname is only present if GNU sh-utils (shellutils, the predecessor to coreutils) is installed (shl2011br2.zip). Likewise for fileutils. Useful GCC, Binutils, Lua 5.2, though. Windows 32-bit only. pakke --initdb to use package manager. No standard install location, although C:\DJGPP preferred and uses environment variables to that effect.
local DJGPP = UnixOnWindowsOperatingSystem:new('MS-DOS', 'DJGPP', {i686 = 'IA-32'})

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'split')
function DJGPP:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText)
	-- Implies Windows version 5.50, which is plain wrong
	-- -v gives '50'; -r gives '5'. There is no DJGPP version
	-- Since we can not actually detect DJGPP version so we assume it's always major '2'. This is unlikely to change given DJGPP's age
	return self:_createVersion(rSwitchText, vSwitchText, '0', self:_createVersion('2', '0', '0', nil))
end
-- i586-pc-msdosdjgpp

-- UnxUtils; last known release (Jan 2016) was in 2007. Increasingly obsolescent, does not support true POSIX features (eg unnamed pipes)
-- Does not provide an useful compilation environment; we should ignore it and use a raw Windows environment
local UnxUtils = UnixOnWindowsOperatingSystem:new('WindowsNT', 'UnxUtils', {x86 = 'IA-32'})

function UnxUtils:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText))
	-- -r and -v are REVERSED to those in DJGPP, etc (ie they're wrong)
	-- We can not detect UnxUtils version
	return self:_createVersion(vSwitchText, rSwitchText, '0', self:_createVersion('0', '0', '0', nil))
end


local MksToolkit = UnixOnWindowsOperatingSystem:new('Windows_NT', 'MKS Toolkit', {
	['386'] = 'IA-32',
	['486'] = 'IA-32',
	['586'] = 'IA-32',
	['2200'] = 'IA-64',
	['8664'] = 'x86_64'
})

function MksToolkit:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText))
	-- We can not detect MKS toolkit version (eg 9.4)	
	return self:_createVersion(rSwitchText, vSwitchText, '0', self:_createVersion('0', '0', '0', nil))
end
