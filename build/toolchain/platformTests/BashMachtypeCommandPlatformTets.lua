--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractCommandPlatformTest = halimede.build.toolchain.platformTests.AbstractCommandPlatformTest
local ShellLanguage = halimede.io.shellScript.ShellLanguage


halimede.moduleclass('BashCommandPlatformTest', AbstractCommandPlatformTest)

local validShellLanguages = {
	ShellLanguage.Posix
}

function module:initialize()
	AbstractCommandPlatformTest.initialize(self, validShellLanguages, 'bash', '-c', 'printf %s $MACHTYPE')
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'find', 'split')
function module:_interpret(rawData)
	if argument:find('\n') ~= nil then
		return false, 'Not exactly one line without a trailing newline'
	end
	
	-- Yosemite: x86_64-apple-darwin14   (14 => Yosemite)
	-- Mavericks: x86_64-apple-darwin13  (13 => Mavericks)
	-- Ubuntu 10.04.4: x86_64-pc-linux-gnu
	-- Ubuntu 12.04.5: x86_64-pc-linux-gnu
	-- Ubuntu 14.04.1: x86_64-pc-linux-gnu
	-- Debian 7.7.0: x86_64-pc-linux-gnu
	-- Debian 6.0.10: x86_64-pc-linux-gnu
	-- Centos 7.0.1406: x86_64-redhat-linux-gnu
	-- FreeBSD 10.1: bash not installed by default
	-- NetBSD 6.1.5: bash not installed by default
	-- NetBSD 5.2.2: bash not installed by default
	-- OpenBSD 5.6: bash not installed by default; when present, x86_64-unknown-openbsd5.6
	-- Cygwin/32bit: i686-pc-cygwin
	-- Debian Wheezy kFreeBSD: x86_64-pc-kfreebsd-gnu
	-- MSYS2/32bit: i686-pc-msys
	-- Haiku: i586-pc-haiku
	
	-- This is a kind of tuple, but it lacks SOME of the revision
	-- On Linux, it includes the C library as a fourth field; on ARM systems, this can also have a suffix of eabi or eabihf
	
	return {
		bashTuple = rawData
	}
end
