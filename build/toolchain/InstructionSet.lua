--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert


local InstructionSet = halimede.moduleclass('InstructionSet')

function module:initialize(name, gnuTupleNamePrefix, is64Bit, isLittleEndian, defaultCpu, gnuTupleSuffixes, ...)
	assert.parameterTypeIsString('name', name)
	assert.parameterTypeIsString('gnuTupleNamePrefix', gnuTupleNamePrefix)
	assert.parameterTypeIsBoolean('is64Bit', is64Bit)
	assert.parameterTypeIsBoolean('isLittleEndian', isLittleEndian)
	assert.parameterTypeIsString('defaultCpu', defaultCpu)
	assert.parameterTypeIsTable('gnuTupleSuffixes', gnuTupleSuffixes)
	
	self.name = name
	self.gnuTupleNamePrefix = gnuTupleNamePrefix
	self.is64Bit = is64Bit
	self.isLittleEndian = isLittleEndian
	self.cpuTypes = {...}
	self.gnuTupleNameLatest = self.versionsInAscendingOrder[#self.versionsInAscendingOrder]
	
	InstructionSet.static[name] = self
end

-- Needs to use -march= rather than -mcpu=
-- Need to populate additional cpu types
InstructionSet:new('IA-32',                          'i',          false, true , 'i686',    {i386 = '386', i486 = '486', i586 = '586', i686 = '686'}, 'i386', 'i486', 'i586', 'pentium-mmx', 'pentiumpro', 'i686', 'pentium2', 'pentium3', 'pentium-m', 'pentium4', 'prescott', 'k6', 'k6-2', 'k6-3', 'athlon', 'athlon-4', 'winchip-c6', 'winchip2', 'c3', 'c3-2', 'geode')

-- Need to populate additional cpu types
InstructionSet:new('x86_64',                         'x86_64',     true,  true , 'x86_64',  {}, 'k8', 'k8-sse3', 'barcelona', 'bdver1', 'bdver2', 'bdver3', 'bdver4', 'btver1', 'btver2', 'nocona', 'core2', 'nehalem', 'westmere', 'sandybridge', 'ivybridge', 'haswell', 'broadwell', 'bonnell', 'silvermont', 'kn1')

-- Need to populate additional cpu types
-- eg x86_64-pc-linux-gnux32
--InstructionSet:new('x32',                         'x86_64',     false, true , 'x86_64', {})


InstructionSet:new('Alpha (64-Bit Little Endian)'    'alpha',      true,  true , 'ev68',    {ev45 = 'ev45', ev5 = 'ev5', ev56 = 'ev56', pca56 = 'pca56', 'ev6', 'ev67', 'ev68'}, 'ev45', 'ev5', 'ev56', 'pca56', 'ev6', 'ev67', 'ev68')

InstructionSet:new('ARC (32-Bit Little Endian)',     'arc',        false, true , 'ARC700',  {}, 'ARC600', 'ARC601', 'ARC700')

InstructionSet:new('ARC (32-Bit Big Endian)',        'arceb',      false, false, 'ARC700',  {}, 'ARC600', 'ARC601', 'ARC700')

-- Needs to use -mcpu= rather than -march=
-- If choosing cortex-a53, probably ought to issue -mfix-cortex-a53-843419 and -mfix-cortex-a53-835769
-- Also need to support +crypto, +fp, +crc features, perhaps via -march=armv8-a+crypto+fp+crc say
InstructionSet:new('ARM (64-bit Little Endian)',     'aarch64',    true,  true , 'generic', {}, 'generic', 'cortex-a53’', 'cortex-a57', 'cortex-a72', 'exynos-m1', 'thunderx', 'xgene1')

InstructionSet:new('ARM (64-bit Big Endian)',        'aarch64_be', true,  false, 'generic', {}, 'generic', 'cortex-a53’', 'cortex-a57', 'cortex-a72', 'exynos-m1', 'thunderx', 'xgene1')

-- eabi variant adds 'eabi' to end of C lib like x32, eg arm*-unknown-linux-${LIBC}eabi
-- eabihf likewise
-- arm*

-- TODO: Confirm whether -mcpu= is actually supported
InstructionSet:new('AVR (32-Bit Big Endian)',        'avr32',      false, false, 'avr32',   {}, 'avr32')

-- '' => cris v10. There are others (older are v0, v3 and v8) but not viable AFAIK via tuple
InstructionSet:new('CRIS (32-Bit Little Endian)'     'cris',       false, true , 'v32',     {v10 = '', v32 = 'v32'}, 'v0', 'v3', 'v8', 'v10', 'v32')

-- Elbrus
-- InstructionSet:new('Elbrus E2K', 'e2k', ????)

-- Fujitsu
InstructionSet:new('FR-V (32-Bit Little Endian)'     'frv',        false, true,  'frv',     {}, 'frv', 'fr550', 'tomcat', 'fr500', 'fr450', 'fr405', 'fr400', 'fr300', 'simple' )

-- Note, on Linux, uname -m does not include MIPS' 'el'..! So no easy way to tell endianness (experiment with Aboriginal Linux releases)
-- Note: There is also a stack of mips processor names to choose from...

InstructionSet:new('MIPS (32-bit Little Endian)',    'mipsel',     false, true,  'mips1',   {}, 'mips1', 'mips2', 'mips32', 'mips32r2')

InstructionSet:new('MIPS (32-bit Big Endian)',       'mips',       false, false, 'mips1',   {}, 'mips1', 'mips2', 'mips32', 'mips32r2')

InstructionSet:new('MIPS (64-bit Little Endian)',    'mips64el',   true,  true , 'mips3',   {}, 'mips3', 'mips4', 'mips64', 'mips64r2')

InstructionSet:new('MIPS (64-bit Big Endian)',       'mips64',     true,  false)

InstructionSet:new('Hexagon (32-bit Little Endian)', 'hexagon',    false, true )


    hexagon:Linux:*:*)
	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
	exit ;;
    i*86:Linux:*:*)
	echo ${UNAME_MACHINE}-pc-linux-${LIBC}
	exit ;;
    ia64:Linux:*:*)
	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
	exit ;;
    k1om:Linux:*:*)
	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
	exit ;;
    m32r*:Linux:*:*)
	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
	exit ;;
    m68*:Linux:*:*)
	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
	exit ;;
    mips:Linux:*:* | mips64:Linux:*:*)
	eval $set_cc_for_build
	sed 's/^	//' << EOF >$dummy.c
	#undef CPU
	#undef ${UNAME_MACHINE}
	#undef ${UNAME_MACHINE}el
	#if defined(__MIPSEL__) || defined(__MIPSEL) || defined(_MIPSEL) || defined(MIPSEL)
	CPU=${UNAME_MACHINE}el
	#else
	#if defined(__MIPSEB__) || defined(__MIPSEB) || defined(_MIPSEB) || defined(MIPSEB)
	CPU=${UNAME_MACHINE}
	#else
	CPU=
	#endif
	#endif
EOF
	eval `$CC_FOR_BUILD -E $dummy.c 2>/dev/null | grep '^CPU'`
	test x"${CPU}" != x && { echo "${CPU}-unknown-linux-${LIBC}"; exit; }
	;;
    openrisc*:Linux:*:*)
	echo or1k-unknown-linux-${LIBC}
	exit ;;
    or32:Linux:*:* | or1k*:Linux:*:*)
	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
	exit ;;
    padre:Linux:*:*)
	echo sparc-unknown-linux-${LIBC}
	exit ;;
    parisc64:Linux:*:* | hppa64:Linux:*:*)
	echo hppa64-unknown-linux-${LIBC}
	exit ;;
    parisc:Linux:*:* | hppa:Linux:*:*)
	# Look for CPU level
	case `grep '^cpu[^a-z]*:' /proc/cpuinfo 2>/dev/null | cut -d' ' -f2` in
	  PA7*) echo hppa1.1-unknown-linux-${LIBC} ;;
	  PA8*) echo hppa2.0-unknown-linux-${LIBC} ;;
	  *)    echo hppa-unknown-linux-${LIBC} ;;
	esac
	exit ;;
    ppc64:Linux:*:*)
	echo powerpc64-unknown-linux-${LIBC}
	exit ;;
    ppc:Linux:*:*)
	echo powerpc-unknown-linux-${LIBC}
	exit ;;
    ppc64le:Linux:*:*)
	echo powerpc64le-unknown-linux-${LIBC}
	exit ;;
    ppcle:Linux:*:*)
	echo powerpcle-unknown-linux-${LIBC}
	exit ;;
    s390:Linux:*:* | s390x:Linux:*:*)
	echo ${UNAME_MACHINE}-ibm-linux-${LIBC}
	exit ;;
    sh64*:Linux:*:*)
	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
	exit ;;
    sh*:Linux:*:*)
	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
	exit ;;
    sparc:Linux:*:* | sparc64:Linux:*:*)
	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
	exit ;;
    tile*:Linux:*:*)
	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
	exit ;;
    vax:Linux:*:*)
	echo ${UNAME_MACHINE}-dec-linux-${LIBC}
	exit ;;
    x86_64:Linux:*:*)
	echo ${UNAME_MACHINE}-pc-linux-${LIBC}
	exit ;;
    xtensa*:Linux:*:*)
	echo ${UNAME_MACHINE}-unknown-linux-${LIBC}
	exit ;;

-- Dead: Alpha, PA-RISC, VAX

local stringEnumerationClass = halimede.enumeration.stringEnumerationClass


-- Similar to Debian architecture but differs, as Debian architecture also includes syscall ABI (effectively, kernel type)
-- Derived from this table https://wiki.debian.org/Multiarch/Tuples
return stringEnumerationClass('InstructionSet',
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
	'PA-RISC', -- Dead
	'PowerPC',
	'PowerPC64',
	'System/390', -- Dead
	'z/Architecture',
	'SH-4',
	'SPARC',
	'SPARC64',
	'x86_64' -- x86_64 (amd64) and x86_64 32-bit
)


