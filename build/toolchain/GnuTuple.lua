--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('halimede.middleclass')
local exception = require('halimede.exception')
local ConfigHDefines = require('halimede.build.defines.ConfigHDefines')
local InstructionSet = requireSibling('InstructionSet')
local ARM64 = InstructionSet.ARM64
local ARM = InstructionSet.ARM
local Alpha = InstructionSet.Alpha
local PARISC = InstructionSet['PA-RISC']
local IA32 = InstructionSet['IA-32']
local IA64 = InstructionSet['IA-64']
local MC68000 = InstructionSet.MC68000
local MIPS = InstructionSet.MIPS
local MIPS64 = InstructionSet.MIPS64
local PowerPC = InstructionSet.PowerPC
local System390 = InstructionSet['System/390']
local zArchitecture = InstructionSet['z/Architecture']
local SH4 = InstructionSet['SH-4']
local Endianness = requireSibling('Endianness')
local SPARC = InstructionSet.SPARC
local SPARC64 = InstructionSet.SPARC64
local x86_64 = InstructionSet.x86_64
local LittleEndian = Endianness.LittleEndian
local BigEndian = Endianness.BigEndian


local function unknownConfigHDefines()
	error('Unknown ConfigH')
end


local function macOsXMavericksConfigHDefines()
	local configHDefines = ConfigHDefines:new()
	
	configHDefines:HAVE_ALLOCA(true)
	configHDefines:HAVE_ALLOCA_H(true)
	configHDefines:HAVE_ATEXIT(true)
	configHDefines:HAVE_CFLOCALECOPYCURRENT(true)
	configHDefines:HAVE_CFPREFERENCESCOPYAPPVALUE(true)
	configHDefines:HAVE_DECL_BSD_SIGNAL(true)
	configHDefines:HAVE_DIRENT_H(true)
	configHDefines:HAVE_DUP(true)
	configHDefines:HAVE_DUP2(true)
	configHDefines:HAVE_FDOPEN(true)
	configHDefines:HAVE_FILENO(true)
	configHDefines:HAVE_GETCWD(true)
	configHDefines:HAVE_GETGROUPS(true)
	configHDefines:HAVE_GETLOADAVG(true)
	configHDefines:HAVE_GETRLIMIT(true)
	configHDefines:HAVE_FCNTL_H(true)
	configHDefines:HAVE_INTTYPES_H(true)
	configHDefines:HAVE_ISATTY(true)
	configHDefines:HAVE_LIMITS_H(true)
	configHDefines:HAVE_LOCALE_H(true)
	configHDefines:HAVE_LSTAT(true)
	configHDefines:HAVE_MEMORY_H(true)
	configHDefines:HAVE_MKSTEMP(true)
	configHDefines:HAVE_MKTEMP(true)
	configHDefines:HAVE_PIPE(true)
	configHDefines:HAVE_READLINK(true)
	configHDefines:HAVE_REALPATH(true)
	configHDefines:HAVE_SETEGID(true)
	configHDefines:HAVE_SETEUID(true)
	configHDefines:HAVE_SETLINEBUF(true)
	configHDefines:HAVE_SETREGID(true)
	configHDefines:HAVE_SETREUID(true)
	configHDefines:HAVE_SETRLIMIT(true)
	configHDefines:HAVE_SETVBUF(true)
	configHDefines:HAVE_SIGACTION(true)
	configHDefines:HAVE_SIGSETMASK(true)
	configHDefines:HAVE_STDINT_H(true)
	configHDefines:HAVE_STDLIB_H(true)
	configHDefines:HAVE_STRCASECMP(true)
	configHDefines:HAVE_STRCOLL(true)
	configHDefines:HAVE_STRDUP(true)
	configHDefines:HAVE_STRERROR(true)
	configHDefines:HAVE_STRINGS_H(true)
	configHDefines:HAVE_STRING_H(true)
	configHDefines:HAVE_STRNCASECMP(true)
	configHDefines:HAVE_STRNDUP(true)
	configHDefines:HAVE_STRSIGNAL(true)
	configHDefines:HAVE_SYS_PARAM_H(true)
	configHDefines:HAVE_SYS_RESOURCE_H(true)
	configHDefines:HAVE_SYS_STAT_H(true)
	configHDefines:HAVE_SYS_TIMEB_H(true)
	configHDefines:HAVE_SYS_TIME_H(true)
	configHDefines:HAVE_SYS_TYPES_H(true)
	configHDefines:HAVE_SYS_WAIT_H(true)
	configHDefines:HAVE_TTYNAME(true)
	configHDefines:HAVE_UNISTD_H(true)
	configHDefines:HAVE_WAIT3(true)
	configHDefines:HAVE_WAITPID(true)
	configHDefines:PATH_SEPARATOR_CHAR(':')
	configHDefines:RETSIGTYPE(requireSibling('RETSIGTYPE').void)
	configHDefines:ST_MTIM_NSEC(requireSibling('ST_MTIM_NSEC')['st_mtimespec.tv_nsec'])
	configHDefines:STDC_HEADERS(true)
	configHDefines:TIME_WITH_SYS_TIME(true)
	configHDefines:_DARWIN_USE_64_BIT_INODE(true)
	
	return configHDefines
end

-- supposedly machine-vendor-operatingSystem, but in reality, a mess, especially as operatingSystem can be two parts (eg x86_64-unknown-linux-gnu)
-- config.guess tries to normalize, but it littered with obsolete systems
-- vendor is typically 'pc' (32-bit i?86 alike), 'unknown' or 'none', and can often be omitted
-- http://wiki.osdev.org/Target_Triplet
-- Also useful: https://bazaar.launchpad.net/~vorlon/+junk/multiarch-tools/view/head:/config.multiarch
-- Also https://gcc.gnu.org/install/specific.html
-- Also config.guess and config.sub (but these are horrid; they latter should just have used a simple 1:1 string key, string value table to normalize so it was easy to spot obsolete entries and reasoning)
local Tuple = class('Tuple')

-- linuxLibC can be gnu, uclibc, dietlibc, musl, newlib, android (?bionic)
-- syscallAbi is a more specialised operatingSystem, effectively 'uname'
-- also need to capture c library kind (eg glibc)
-- vendor is called MANUFACTURER by config.sub
function GnuTuple:initialize(triplet, vendor, syscallAbi, linuxLibC, instructionSet, endianness, wordSize, description, newConfigHDefines)
	assert.parameterTypeIsString(triplet)
	assert.parameterTypeIsString(vendor)
	assert.parameterTypeIsString(syscallAbi)
	assert.parameterTypeIsString(linuxLibC)
	assert.parameterTypeIsInstanceOf(instructionSet, InstructionSet)
	assert.parameterTypeIsInstanceOf(endianness, Endianness)
	assert.parameterTypeIsNumber(wordSize)
	assert.parameterTypeIsString(description)
	assert.parameterTypeIsFunctionOrCall(newConfigHDefines)
	
	if wordSize ~= 32 and wordSize ~= 64 then 
		exception.throw("wordSize can only be 32 or 64 currently, not '%s'", wordSize)
	end
	
	self.triplet = triplet
	self.vendor = vendor
	self.syscallAbi = syscallAbi
	self.linuxLibC = linuxLibC
	self.instructionSet = instructionSet
	self.endianness = endianness
	self.wordSize = wordSize
	self.description = description
	self._newConfigHDefines = newConfigHDefines
	
	self.isPosix = false
	self.isLinux = false
	self.isBsd = false
	self.isMacOsX = false
	
	if syscallAbi == 'linux' then
		self.isPosix = true
		self.isLinux = true
	elseif syscallAbi == 'Darwin' then
		self.isPosix = true
		self.isBsd = true
		self.isMacOsX = true
	end
	
	GnuTuple.static[gnuTriplet] = self
end

function GnuTuple:isUnknown()
	-- ? what about 'none' ?
	return self.vendor == 'unknown' or self.vendor == 'pc'
end

function GnuTuple:newConfigHDefines()
	return self._newConfigHDefines()
end





-- Linux

GnuTuple:new('aarch64-linux-gnu', 'unknown', 'linux', 'glibc', ARM64, LittleEndian, 64, 'aarch64 Linux Platform (Little Endian)', unknownConfigHDefines)
GnuTuple:new('aarch64_be-linux-gnu', 'unknown', 'linux', 'glibc', ARM64, BigEndian, 64, 'aarch64 Linux Platform (Big Endian)', unknownConfigHDefines)

-- These effectively represent Alpha instruction set variants that GCC understands
GnuTuple:new('alphaev5-unknown-linux-gnu', 'unknown', 'linux', 'glibc', Alpha, LittleEndian, 64, 'glibc, Tru64 calling standard', unknownConfigHDefines)
GnuTuple:new('alphaev56-unknown-linux-gnu', 'unknown', 'linux', 'glibc', Alpha, LittleEndian, 64, 'glibc, Tru64 calling standard', unknownConfigHDefines)
GnuTuple:new('alphapca56-unknown-linux-gnu', 'unknown', 'linux', 'glibc', Alpha, LittleEndian, 64, 'glibc, Tru64 calling standard', unknownConfigHDefines)
GnuTuple:new('alphaev6-unknown-linux-gnu', 'unknown', 'linux', 'glibc', Alpha, LittleEndian, 64, 'glibc, Tru64 calling standard', unknownConfigHDefines)
GnuTuple:new('alphaev67-unknown-linux-gnu', 'unknown', 'linux', 'glibc', Alpha, LittleEndian, 64, 'glibc, Tru64 calling standard', unknownConfigHDefines)
GnuTuple:new('alphaev68-unknown-linux-gnu', 'unknown', 'linux', 'glibc', Alpha, LittleEndian, 64, 'glibc, Tru64 calling standard', unknownConfigHDefines)

GnuTuple:new('i386-pc-linux-gnu', 'pc', 'linux', 'glibc', IA32, LittleEndian, 32, 'LSB IA32', unknownConfigHDefines)
GnuTuple:new('i486-pc-linux-gnu', 'pc', 'linux', 'glibc', IA32, LittleEndian, 32, 'LSB IA32', unknownConfigHDefines)
GnuTuple:new('i586-pc-linux-gnu', 'pc', 'linux', 'glibc', IA32, LittleEndian, 32, 'LSB IA32', unknownConfigHDefines)
GnuTuple:new('i686-pc-linux-gnu', 'pc', 'linux', 'glibc', IA32, LittleEndian, 32, 'LSB IA32', unknownConfigHDefines)

GnuTuple:new('x86_64-pc-linux-gnu', 'unknown', 'linux', 'glibc', x86_64, LittleEndian, 64, 'LSB AMD64', unknownConfigHDefines)
GnuTuple:new('x86_64-pc-linux-gnux32', 'unknown', 'linux', 'glibc', x86_64, LittleEndian, 32, 'glibc Linux x32', unknownConfigHDefines)

GnuTuple:new('arc-linux-uclibc', 'unknown', 'linux', 'uclibc', ARC, LittleEndian, 32, 'uclibc Linux ARC', unknownConfigHDefines)
GnuTuple:new('cris-axis-linux-gnu', 'axis', 'linux', 'glibc', CRIS, LittleEndian, 32, 'CRIS Linux', unknownConfigHDefines)


-- Apple sticks to machine-vendor-operatingSystem
GnuTuple:new('x86_64-apple-darwin13.4.0', 'apple', 'Darwin', nil, x86_64, LittleEndian, 64, 'Mac OS X 10.9 (Mavericks)', macOsXMavericksConfigHDefines)
GnuTuple.static['x86_64-apple-darwin13.4.0'].isMacOsXMavericks = true
-- TODO: Probably wrong: macOsXMavericksConfigHDefines
GnuTuple:new('x86_64-apple-darwin14', 'apple', 'Darwin', nil, x86_64, LittleEndian, 64, 'Mac OS X 10.10 (Yosemite)', macOsXMavericksConfigHDefines)
GnuTuple.static['x86_64-apple-darwin14'].isMacOsXYosemite = true
