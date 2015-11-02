--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('halimede.middleclass')
local exception = require('halimede.exception')
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
function GnuTuple:initialize(gnuTriplet, vendor, syscallAbi, linuxLibC, instructionSet, endianness, wordSize, description)
	assert.parameterTypeIsString(gnuTriplet)
	assert.parameterTypeIsString(vendor)
	assert.parameterTypeIsString(syscallAbi)
	assert.parameterTypeIsString(linuxLibC)
	assert.parameterTypeIsInstanceOf(instructionSet, InstructionSet)
	assert.parameterTypeIsInstanceOf(endianness, Endianness)
	assert.parameterTypeIsNumber(wordSize)
	assert.parameterTypeIsString(description)
	
	if wordSize ~= 32 and wordSize ~= 64 then 
		exception.throw("wordSize can only be 32 or 64 currently, not '%s'", wordSize)
	end
	
	self.gnuTriplet = gnuTriplet
	self.vendor = vendor
	self.syscallAbi = syscallAbi
	self.linuxLibC = linuxLibC
	self.instructionSet = instructionSet
	self.endianness = endianness
	self.wordSize = wordSize
	self.description = description
	
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




-- Linux

GnuTuple:new('aarch64-linux-gnu', 'unknown', 'linux', 'glibc', ARM64, LittleEndian, 64, 'aarch64 Linux Platform (Little Endian)')
GnuTuple:new('aarch64_be-linux-gnu', 'unknown', 'linux', 'glibc', ARM64, BigEndian, 64, 'aarch64 Linux Platform (Big Endian)')

-- These effectively represent Alpha instruction set variants that GCC understands
GnuTuple:new('alphaev5-unknown-linux-gnu', 'unknown', 'linux', 'glibc', Alpha, LittleEndian, 64, 'glibc, Tru64 calling standard')
GnuTuple:new('alphaev56-unknown-linux-gnu', 'unknown', 'linux', 'glibc', Alpha, LittleEndian, 64, 'glibc, Tru64 calling standard')
GnuTuple:new('alphapca56-unknown-linux-gnu', 'unknown', 'linux', 'glibc', Alpha, LittleEndian, 64, 'glibc, Tru64 calling standard')
GnuTuple:new('alphaev6-unknown-linux-gnu', 'unknown', 'linux', 'glibc', Alpha, LittleEndian, 64, 'glibc, Tru64 calling standard')
GnuTuple:new('alphaev67-unknown-linux-gnu', 'unknown', 'linux', 'glibc', Alpha, LittleEndian, 64, 'glibc, Tru64 calling standard')
GnuTuple:new('alphaev68-unknown-linux-gnu', 'unknown', 'linux', 'glibc', Alpha, LittleEndian, 64, 'glibc, Tru64 calling standard')

GnuTuple:new('i386-pc-linux-gnu', 'pc', 'linux', 'glibc', IA32, LittleEndian, 32, 'LSB IA32')
GnuTuple:new('i486-pc-linux-gnu', 'pc', 'linux', 'glibc', IA32, LittleEndian, 32, 'LSB IA32')
GnuTuple:new('i586-pc-linux-gnu', 'pc', 'linux', 'glibc', IA32, LittleEndian, 32, 'LSB IA32')
GnuTuple:new('i686-pc-linux-gnu', 'pc', 'linux', 'glibc', IA32, LittleEndian, 32, 'LSB IA32')

GnuTuple:new('x86_64-pc-linux-gnu', 'unknown', 'linux', 'glibc', x86_64, LittleEndian, 64, 'LSB AMD64')
GnuTuple:new('x86_64-pc-linux-gnux32', 'unknown', 'linux', 'glibc', x86_64, LittleEndian, 32, 'glibc Linux x32')

GnuTuple:new('arc-linux-uclibc', 'unknown', 'linux', 'uclibc', ARC, LittleEndian, 32, 'uclibc Linux ARC')
GnuTuple:new('cris-axis-linux-gnu', 'axis', 'linux', 'glibc', CRIS, LittleEndian, 32, 'uclibc Linux ARC')


-- Apple sticks to machine-vendor-operatingSystem
GnuTuple:new('x86_64-apple-darwin13.4.0', 'apple', 'Darwin', nil, x86_64, LittleEndian, 64, 'Mac OS X 10.9 (Mavericks)')
GnuTuple.static['x86_64-apple-darwin13.4.0'].isMacOsXMavericks = true
GnuTuple:new('x86_64-apple-darwin14', 'apple', 'Darwin', nil, x86_64, LittleEndian, 64, 'Mac OS X 10.10 (Yosemite)')
GnuTuple.static['x86_64-apple-darwin14'].isMacOsXYosemite = true
