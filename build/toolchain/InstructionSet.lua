--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local stringEnumerationClass = require('halimede.enumeration').stringEnumerationClass


-- Similar to Debian architecture but differs, as Debian architecture also includes syscall ABI (effectively, kernel type)
-- Derived from this table https://wiki.debian.org/Multiarch/Tuples
local InstructionSet = stringEnumerationClass('InstructionSet',
	'ARC',
	'Alpha', -- Dead
	'ARM',
	'ARM64',
	'CRIS',
	'IA-32', -- Everything i?86 pre x86_64
	'IA-64', -- Itanium
	'MC68000',
	'MIPS',
	'MIPS64',
	'PA-RISC', -- Nearly Dead
	'PowerPC',
	'System/390', -- Dead
	'z/Architecture',
	'SH-4',
	'SPARC',
	'SPARC64'
	'x86_64', -- x86_64 (amd64) and x86_64 32-bit
)

return InstructionSet
