--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert



-- Determine if uname is available
	-- Can use Bash's OSTYPE / MACHTYPE
-- Determine if we're running on Windows (could use folder separator; naive but effective)
-- Or use LuaJIT again
-- jit.os

-- if have uname, if we have bash, we can use bash's MACHTYPE to get the GNU tuple (synthetic env var)
	-- On Yosemite => x86_64-apple-darwin14
	-- Hmm, on Mavericks => x86_64-apple-darwin13
	-- BUT clang reports as x86_64-apple-darwin13.4.0
	-- we need to normalise these back
-- Can use clang -v to get Target: x86_64-apple-darwin13.4.0 (also the Apple gcc wrapper)
-- Can use gcc -v likewise
-- Add support for running scripts with environment variables set / unset
	-- can use the 'env' program (usually at /usr/bin/env)
		-- not on Windows
	-- can use VAR=VALUE progname style (? problematic on some AIX shells)
	-- can generate a mini-script
		-- overhead, but effective for Windows


local shellLanguage = halimede.io.shellScript.ShellLanguage.default()
local function uname()
	if shellLanguage:commandIsOnPathAndShellIsAvaiableToUseIt('uname')
end

local 


Alternatively, we can test by Operating System we're on


- MacOS X tests
- NetBSD tests
- OpenBSD tests
- FreeBSD tests


uname -a
uname -p


DJGPP
Midipix
and all the other Windows options
? OpenVMS
Solaris versions
HP/UX
AIX
? RiscOS
Haiku
Minix
Amiga
