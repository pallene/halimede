--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractCommandPlatformTest = halimede.build.toolchain.platformTests
local ShellLanguage = halimede.io.shellScript.ShellLanguage


halimede.moduleclass('UnameCommandPlatformTest', AbstractCommandPlatformTest)

local validShellLanguages = {
	ShellLanguage.Posix
}

-- affected by LANG, LC_ALL, LC_CTYPE, LC_MESSAGES, NLSPATH; we need a clean-environment approach
function module:initialize()
	AbstractCommandPlatformTest.initialize(self, validShellLanguages, 'uname', '-s', '-r', '-m')
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'split')
function module:_interpret(rawData)
	
	-- Yosemite: Darwin 14.5.0 x86_64   (14 => Yosemite)
	-- Mavericks: Darwin 13.4.0 x86_64  (13 => Mavericks)
	-- Ubuntu 10.04.4: Linux 2.6.32-74-server x86_64
	-- Ubuntu 12.04.5: Linux 3.13.0-43-generic x86_64
	-- Ubuntu 14.04.1: Linux 3.13.0-49-generic x86_64
	-- Debian 7.7.0: Linux 3.2.0-4-amd64 x86_64
	-- Debian 6.0.10: Linux 2.6.32-5-amd64 x86_64
	-- Centos 7.0.1406: Linux 3.10.0-123.13.1.el7.x86_64 x86_64
	-- FreeBSD 10.1: FreeBSD 10.1-RELEASE amd64
		-- freebsd-version: 10.1-RELEASE
	-- NetBSD 6.1.5: NetBSD 6.1.5 amd64
	-- NetBSD 5.2.2: NetBSD 5.2.2 amd64
	-- OpenBSD 5.6: OpenBSD 5.6 amd64
	-- Cygwin/32bit: CYGWIN_NT-6.0 2.3.1(0.291/5/3) i686
	
	-- MKS uname https://www.mkssoftware.com/docs/man1/uname.1.asp
		-- operatingSystemName is Windows_NT for everything
		-- release will be one of 5 (Windows Server 2003), 6 (Windows Vista => Windows Server 2012), or 10 (Windows 10)
			-- Windows Vista is the first release to support soft symlinks, and should be our minimum supported version
		-- hardwareType will display 386/486/586 and 2220 (IA64) or 8664 (AMD64/EM64T)
	
	-- Should result in OS, Release, Processor ~= gnu tuple
	-- Note that gcc-4.9 produces a target of Darwin14.4.0 vs a uname -r of 14.5.0; probably due to the fact that gcc-4.9 in this case is a homebrew bottle built on a different machine [potential gotcha]
	
	local lines = rawData:split('\n')
	if #lines ~= 2 then
		return false, 'Not exactly one line terminated by newline'
	end
	
	if #lines[2] ~= 0 then
		return false, 'Not exactly one line terminated by newline; subsequent line has content'
	end
	
	local line = lines[1]
	line:split(' ')
	if #line ~= 3 then
		return false, "Does not contain space-separated operating system implementation name (eg 'Darwin'), hardware type (eg 'x86_64') and release (eg '14.5.0')"
	end
	
	return {
		operatingSystemName = line[1],
		release = line[2],
		hardwareType = line[3],
	}
end
