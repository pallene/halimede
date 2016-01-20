--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractCommandPlatformTest = halimede.build.toolchain.platformTests.AbstractCommandPlatformTest
local ShellLanguage = halimede.io.shellScript.ShellLanguage


halimede.moduleclass('GccCommandPlatformTest', AbstractCommandPlatformTest)

local validShellLanguages = {
	ShellLanguage.Posix
}

-- affected by LANG, LC_ALL, LC_CTYPE, LC_MESSAGES, NLSPATH and others; we need a clean-environment approach
function module:initialize()
	AbstractCommandPlatformTest.initialize(self, validShellLanguages, 'gcc', '-v')
end

-- ? switch to gcc -dumpmachine ?
local lineStartsWith = 'Target: '
local lineStartsWithLength = #lineStartsWith
local remainderOfLineStartsAt = lineStartsWithLength + 1
assert.globalTypeIsFunctionOrCall('ipairs')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'split')
function module:_interpret(rawData)
	
	-- Yosemite: x86_64-apple-darwin14.5.0 (if using system gcc)
	-- Mavericks: x86_64-apple-darwin13.4.0 (if using system gcc)
	-- Ubuntu 10.04.4: x86_64-linux-gnu [system gcc 4.4; note that -pc is missing]! (not installed by default)
	-- Ubuntu 12.04.5: x86_64-linux-gnu [system gcc 4.6; note that -pc is missing]! (not installed by default)
	-- Ubuntu 14.04.1: x86_64-linux-gnu [system gcc 4.8; note that -pc is missing]! (not installed by default)
	-- Debian 7.7.0: 
	-- Debian 6.0.10: (not installed by default)
	-- Centos 7.0.1406: 
	-- FreeBSD 10.1: 
	-- NetBSD 6.1.5: 
	-- NetBSD 5.2.2: 
	-- OpenBSD 5.6: amd64-unknown-openbsd5.6 [gcc 4.2.1]
	-- Cygwin/32bit: i686-pc-cygwin (not installed by default, several choices, used gcc-core)
	-- Debian Wheezy kFreeBSD: x86_64-kfreebsd-gnu (not installed by default - also sudo isn't, either; gcc 4.7.2)
		-- But clang reports x86_64-pc-kfreebsd-gnu
	-- Solaris 11.3: i386-pc-solaris2.11
	-- Haiku: doesn't work, -dumpmachine produces i586-pc-haiku
	-- DJGPP: djgpp (no hyphens) [only 32-bit Windows, gcc 5.3.0]
	
	-- Note that this test isn't as good
	-- For example, on a Yosemite machine with Homebrew installed, gcc-4.9 produces a target 'x86_64-apple-darwin14.4.0' even thought the target ought to be 'x86_64-apple-darwin14.5.0', due to the fact that this is a homebrew bottle built on a different machine [potential gotcha]
	-- Likewise, Mac OS X's default gcc fakes gcc using clang and has a different command output, although a similar line is present
	
	
	-- Look for a line that starts 'Target: TUPLE\n'
	local lines = rawData:split('\n')
	for _, line in ipairs(lines) do
		if line:sub(1, lineStartsWithLength) == lineStartsWith then
			return {
				gccTuple: line:sub(remainderOfLineStartsAt)
			}
		end
	end
	
	return false, "Could not find matching line"
end

