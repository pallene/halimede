--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception
local tabelize = halimede.table.tabelize


-- https://github.com/llvm-mirror/clang/blob/master/lib/Driver/ToolChains.cpp is useful
local InstructionSet = halimede.moduleclass('InstructionSet')

assert.globalTypeIsFunctionOrCall('ipairs')
function module:initialize(name, gnuTupleNamePrefix, gnuTupleSuffix, is64Bit, isLittleEndian, gccCpuSwitch, defaultCpu, gnuTupleSuffixes, ...)
	assert.parameterTypeIsString('name', name)
	assert.parameterTypeIsString('gnuTupleNamePrefix', gnuTupleNamePrefix)
	assert.parameterTypeIsString('gnuTupleSuffix', gnuTupleSuffix)
	assert.parameterTypeIsBoolean('is64Bit', is64Bit)
	assert.parameterTypeIsBoolean('isLittleEndian', isLittleEndian)
	assert.parameterTypeIsStringOrNil('gccCpuSwitch', gccCpuSwitch)
	assert.parameterTypeIsStringOrNil('defaultCpu', defaultCpu)
	assert.parameterTypeIsTable('gnuTupleSuffixes', gnuTupleSuffixes)
	
	local cpus = tabelize({...})
	guardDefaultCpuIsPresent(defaultCpu, cpus, gccCpuSwitch)
	
	self.name = name
	self.gnuTupleNamePrefix = gnuTupleNamePrefix
	self.gnuTupleSuffix = gnuTupleSuffix
	self.is64Bit = is64Bit
	self.isLittleEndian = isLittleEndian
	self.gccCpuSwitch = gccCpuSwitch
	self.defaultCpu = defaultCpu
	self.gnuTupleSuffixes = gnuTupleSuffixes
	self.cpus = cpus
	
	InstructionSet.static[name] = self
end

local function guardDefaultCpuIsPresent(defaultCpu, cpus, gccCpuSwitch)
	if defaultCpu == nil then
		if #cpus ~= 0 then
			exception.throw('cpus can not be non-empty if defaultCpu is nil')
		end
		if gccCpuSwitch ~= nil then
			exception.throw("gccCpuSwitch can not be a value if defaultCpu is nil")
		end
		return
	end
	if gccCpuSwitch == nil then
		exception.throw("gccCpuSwitch can not nil if there is a defaultCpu")
	end
	for _, cpu in ipairs(cpus) do
		if cpu == defaultCpu then
			return
		end
	end
	exception.throw("cpus does not contain default cpu '%s'", defaultCpu)
end

local function instructionSet(simpleName, nameSuffix, commonestGnuName, gnuSuffix, is64Bit, isLittleEndian)
	
	local bits
	if namePrefix == 'S/390' and gnuName == 's390' and is64Bit == false then
		bits == '31'
	else
		bits == is64Bit and '64' or '32'
	end
	
	local endianness = isLittleEndian and 'Little' or 'Big'
	
	local suffix
	if #nameSuffix > 0 then
		suffix = ' ' .. nameSuffix
	else
		suffix = ''
	end
	
	local name == ("%s (%s-Bit %s Endian)", simpleName, bits, endianness, suffix)
	
	return InstructionSet:new(name, )
end


local SubArchitecture = halimede.moduleclass('SubArchitecture')

-- Doesn't address more complex switch combinations (eg mips ABI, eg mips fp settings, etc)
function SubArchitecture:initialize(name, cpuOrArchitectureSwitch, tuneSwitch, gnuProcessorVariant)
	assert.parameterTypeIsString('name', name)
	assert.parameterTypeIsStringOrNil('cpuOrArchitectureSwitch', cpuOrArchitectureSwitch)
	assert.parameterTypeIsStringOrNil('tuneSwitch', tuneSwitch)
	assert.parameterTypeIsStringOrNil('gnuProcessorVariant', gnuProcessorVariant)
	
	if cpuOrArchitectureSwitch == nil and tuneSwitch == nil then
		exception.throw('cpuOrArchitectureSwitch and tuneSwitch can not both be nil')
	end
	
	if gnuProcessorVariant ~= nil and cpuOrArchitectureSwitch == nil then
		exception.throw('cpuOrArchitectureSwitch can not be nil if gnuProcessorVariant is not')
	end
	
	self.name = name
	self.cpuOrArchitectureSwitch = cpuOrArchitectureSwitch
	self.tuneSwitch = tuneSwitch
	self.gnuProcessorVariant = gnuProcessorVariant
end

local function subArchitecture(...)
	return SubArchitecture:new(...)
end

local ThirtyOneBit = false
local ThirtyTwoBit = false
local SixtyFourBit = true

local LittleEndian = true
local BigEndian = false
instructionSet('Alpha', '', 'alphaev45', '', SixtyFourBit, BigEndian, 
	subArchitecture('ev45', '-mcpu=ev45', '-mtune=ev45', 'alphaev45'),
	...
)

-- Current variants:-
-- Renesas M32R and SH*: switch(es) per cpu
-- i686, CRIS: Tuple Name or -march= -mtune= but with less tuple names than arch options
-- PA-RISC, Alpha: Tuple Name or -mcpu=/-mtune= but with equal tuple names to arch options
-- MIPS, PowerPC: No tuple names, -mcpu= / -mtune=
-- IA64: No tuples names, just -mtune=
-- arm 32-bit: ???




instructionSet('Alpha (64-Bit Little Endian)'                          'alpha',         '',       true,  true , '-mcpu=',  'ev68',           {ev45 = 'ev45', ev5 = 'ev5', ev56 = 'ev56', pca56 = 'pca56', ev6 = 'ev6', ev67 = 'ev67', ev68 = 'ev68'}, 'ev45', 'ev5', 'ev56', 'pca56', 'ev6', 'ev67', 'ev68')

instructionSet('ARC (32-Bit Little Endian)',                           'arc',           '',       false, true , '-mcpu=',  'ARC700',         {}, 'ARC600', 'ARC601', 'ARC700')

instructionSet('ARC (32-Bit Big Endian)',                              'arceb',         '',       false, false, '-mcpu=',  'ARC700',         {}, 'ARC600', 'ARC601', 'ARC700')

-- arm-linux-gnu (DEAD); some of the CPUs are almost certainly inappropriate
instructionSet('ARM (32-Bit Little Endian) OABI Soft Float',           'arm'            '',       false, true , '-mcpu=',  'generic-armv2',  {}, 'generic-armv2', 'generic-armv2a', 'generic-armv3', 'generic-armv3m', 'generic-armv4', 'generic-armv4t', 'generic-armv5', 'generic-armv5t', 'generic-armv5e', 'generic-armv5te', 'generic-armv6', 'generic-armv6j', 'generic-armv6t2', 'generic-armv6z', 'generic-armv6zk', 'generic-armv6-m', 'generic-armv7', 'generic-armv7-a', 'generic-armv7-r', 'generic-armv7-m', 'generic-armv7e-m', 'generic-armv7ve', 'generic-armv8-a', 'generic-armv8-a+crc', 'generic-iwmmxt', 'generic-iwmmxt2', 'generic-ep9312', 'arm2', 'arm250', 'arm3', 'arm6', 'arm60', 'arm600', 'arm610', 'arm620', 'arm7', 'arm7m', 'arm7d', 'arm7dm', 'arm7di', 'arm7dmi', 'arm70', 'arm700', 'arm700i', 'arm710', 'arm710c', 'arm7100', 'arm720', 'arm7500', 'arm7500fe', 'arm7tdmi', 'arm7tdmi-s', 'arm710t', 'arm720t', 'arm740t', 'strongarm', 'strongarm110', 'strongarm1100', 'strongarm1110', 'arm8', 'arm810', 'arm9', 'arm9e', 'arm920', 'arm920t', 'arm922t', 'arm946e-s', 'arm966e-s', 'arm968e-s', 'arm926ej-s', 'arm940t', 'arm9tdmi', 'arm10tdmi', 'arm1020t', 'arm1026ej-s', 'arm10e', 'arm1020e', 'arm1022e', 'arm1136j-s', 'arm1136jf-s', 'mpcore', 'mpcorenovfp', 'arm1156t2-s', 'arm1156t2f-s', 'arm1176jz-s', 'arm1176jzf-s', 'cortex-a5', 'cortex-a7', 'cortex-a8', 'cortex-a9', 'cortex-a12', 'cortex-a15', 'cortex-a53', 'cortex-a57', 'cortex-a72', 'cortex-r4', 'cortex-r4f', 'cortex-r5', 'cortex-r7', 'cortex-m7', 'cortex-m4', 'cortex-m3', 'cortex-m1', 'cortex-m0', 'cortex-m0plus', 'cortex-m1.small-multiply', 'cortex-m0.small-multiply', 'cortex-m0plus.small-multiply', 'exynos-m1', 'marvell-pj4', 'xscale', 'iwmmxt', 'iwmmxt2', 'ep9312', 'fa526', 'fa626', 'fa606te', 'fa626te', 'fmp626', 'fa726te', 'xgene1', 'cortex-a15.cortex-a7', 'cortex-a57.cortex-a53', 'cortex-a72.cortex-a53')

-- arm-linux-gnueabi; some of the CPUs are almost certainly inappropriate
instructionSet('ARM (32-Bit Little Endian) EABI Soft Float',           'arm',           'eabi',   false, true , '-mcpu=',  'generic-armv4t', {}, 'generic-armv4t', 'generic-armv5', 'generic-armv5t', 'generic-armv5e', 'generic-armv5te', 'generic-armv6', 'generic-armv6j', 'generic-armv6t2', 'generic-armv6z', 'generic-armv6zk', 'generic-armv6-m', 'generic-armv7', 'generic-armv7-a', 'generic-armv7-r', 'generic-armv7-m', 'generic-armv7e-m', 'generic-armv7ve', 'generic-armv8-a', 'generic-armv8-a+crc', 'generic-iwmmxt', 'generic-iwmmxt2', 'generic-ep9312', 'arm2', 'arm250', 'arm3', 'arm6', 'arm60', 'arm600', 'arm610', 'arm620', 'arm7', 'arm7m', 'arm7d', 'arm7dm', 'arm7di', 'arm7dmi', 'arm70', 'arm700', 'arm700i', 'arm710', 'arm710c', 'arm7100', 'arm720', 'arm7500', 'arm7500fe', 'arm7tdmi', 'arm7tdmi-s', 'arm710t', 'arm720t', 'arm740t', 'strongarm', 'strongarm110', 'strongarm1100', 'strongarm1110', 'arm8', 'arm810', 'arm9', 'arm9e', 'arm920', 'arm920t', 'arm922t', 'arm946e-s', 'arm966e-s', 'arm968e-s', 'arm926ej-s', 'arm940t', 'arm9tdmi', 'arm10tdmi', 'arm1020t', 'arm1026ej-s', 'arm10e', 'arm1020e', 'arm1022e', 'arm1136j-s', 'arm1136jf-s', 'mpcore', 'mpcorenovfp', 'arm1156t2-s', 'arm1156t2f-s', 'arm1176jz-s', 'arm1176jzf-s', 'cortex-a5', 'cortex-a7', 'cortex-a8', 'cortex-a9', 'cortex-a12', 'cortex-a15', 'cortex-a53', 'cortex-a57', 'cortex-a72', 'cortex-r4', 'cortex-r4f', 'cortex-r5', 'cortex-r7', 'cortex-m7', 'cortex-m4', 'cortex-m3', 'cortex-m1', 'cortex-m0', 'cortex-m0plus', 'cortex-m1.small-multiply', 'cortex-m0.small-multiply', 'cortex-m0plus.small-multiply', 'exynos-m1', 'marvell-pj4', 'xscale', 'iwmmxt', 'iwmmxt2', 'ep9312', 'fa526', 'fa626', 'fa606te', 'fa626te', 'fmp626', 'fa726te', 'xgene1', 'cortex-a15.cortex-a7', 'cortex-a57.cortex-a53', 'cortex-a72.cortex-a53')

-- arm-linux-gnueabihf; some of the CPUs are almost certainly inappropriate; some need adding to support Raspberry A / B (As these are armv6 hard float)
instructionSet('ARM (32-Bit Little Endian) EABI Hard Float',           'arm',           'eabihf', false, true , '-mcpu=',  'generic-armv7',  {}, 'generic-armv7', 'generic-armv7-a', 'generic-armv7-r', 'generic-armv7-m', 'generic-armv7e-m', 'generic-armv7ve', 'generic-armv8-a', 'generic-armv8-a+crc', 'generic-iwmmxt', 'generic-iwmmxt2', 'generic-ep9312', 'arm7', 'arm7m', 'arm7d', 'arm7dm', 'arm7di', 'arm7dmi', 'arm70', 'arm700', 'arm700i', 'arm710', 'arm710c', 'arm7100', 'arm720', 'arm7500', 'arm7500fe', 'arm7tdmi', 'arm7tdmi-s', 'arm710t', 'arm720t', 'arm740t', 'strongarm', 'strongarm110', 'strongarm1100', 'strongarm1110', 'arm8', 'arm810', 'arm9', 'arm9e', 'arm920', 'arm920t', 'arm922t', 'arm946e-s', 'arm966e-s', 'arm968e-s', 'arm926ej-s', 'arm940t', 'arm9tdmi', 'arm10tdmi', 'arm1020t', 'arm1026ej-s', 'arm10e', 'arm1020e', 'arm1022e', 'arm1136j-s', 'arm1136jf-s', 'mpcore', 'mpcorenovfp', 'arm1156t2-s', 'arm1156t2f-s', 'arm1176jz-s', 'arm1176jzf-s', 'cortex-a5', 'cortex-a7', 'cortex-a8', 'cortex-a9', 'cortex-a12', 'cortex-a15', 'cortex-a53', 'cortex-a57', 'cortex-a72', 'cortex-r4', 'cortex-r4f', 'cortex-r5', 'cortex-r7', 'cortex-m7', 'cortex-m4', 'cortex-m3', 'cortex-m1', 'cortex-m0', 'cortex-m0plus', 'cortex-m1.small-multiply', 'cortex-m0.small-multiply', 'cortex-m0plus.small-multiply', 'exynos-m1', 'marvell-pj4', 'xscale', 'iwmmxt', 'iwmmxt2', 'ep9312', 'fa526', 'fa626', 'fa606te', 'fa626te', 'fmp626', 'fa726te', 'xgene1', 'cortex-a15.cortex-a7', 'cortex-a57.cortex-a53', 'cortex-a72.cortex-a53')

-- armeb-linux-gnueabi; some of the CPUs are almost certainly inappropriate
instructionSet('ARM (32-Bit Big Endian) EABI Soft Float',              'armeb',         'eabi',   false, true , '-mcpu=',  'generic-armv7',  {}, 'generic-armv7', 'generic-armv7-a', 'generic-armv7-r', 'generic-armv7-m', 'generic-armv7e-m', 'generic-armv7ve', 'generic-armv8-a', 'generic-armv8-a+crc', 'generic-iwmmxt', 'generic-iwmmxt2', 'generic-ep9312', 'arm7', 'arm7m', 'arm7d', 'arm7dm', 'arm7di', 'arm7dmi', 'arm70', 'arm700', 'arm700i', 'arm710', 'arm710c', 'arm7100', 'arm720', 'arm7500', 'arm7500fe', 'arm7tdmi', 'arm7tdmi-s', 'arm710t', 'arm720t', 'arm740t', 'strongarm', 'strongarm110', 'strongarm1100', 'strongarm1110', 'arm8', 'arm810', 'arm9', 'arm9e', 'arm920', 'arm920t', 'arm922t', 'arm946e-s', 'arm966e-s', 'arm968e-s', 'arm926ej-s', 'arm940t', 'arm9tdmi', 'arm10tdmi', 'arm1020t', 'arm1026ej-s', 'arm10e', 'arm1020e', 'arm1022e', 'arm1136j-s', 'arm1136jf-s', 'mpcore', 'mpcorenovfp', 'arm1156t2-s', 'arm1156t2f-s', 'arm1176jz-s', 'arm1176jzf-s', 'cortex-a5', 'cortex-a7', 'cortex-a8', 'cortex-a9', 'cortex-a12', 'cortex-a15', 'cortex-a53', 'cortex-a57', 'cortex-a72', 'cortex-r4', 'cortex-r4f', 'cortex-r5', 'cortex-r7', 'cortex-m7', 'cortex-m4', 'cortex-m3', 'cortex-m1', 'cortex-m0', 'cortex-m0plus', 'cortex-m1.small-multiply', 'cortex-m0.small-multiply', 'cortex-m0plus.small-multiply', 'exynos-m1', 'marvell-pj4', 'xscale', 'iwmmxt', 'iwmmxt2', 'ep9312', 'fa526', 'fa626', 'fa606te', 'fa626te', 'fmp626', 'fa726te', 'xgene1', 'cortex-a15.cortex-a7', 'cortex-a57.cortex-a53', 'cortex-a72.cortex-a53')

-- armeb-linux-gnueabihf; some of the CPUs are almost certainly inappropriate
instructionSet('ARM (32-Bit Big Endian) EABI Hard Float',              'armeb',         'eabihf', false, true , '-mcpu=',  'generic-armv7',  {}, 'generic-armv7', 'generic-armv7-a', 'generic-armv7-r', 'generic-armv7-m', 'generic-armv7e-m', 'generic-armv7ve', 'generic-armv8-a', 'generic-armv8-a+crc', 'generic-iwmmxt', 'generic-iwmmxt2', 'generic-ep9312', 'arm7', 'arm7m', 'arm7d', 'arm7dm', 'arm7di', 'arm7dmi', 'arm70', 'arm700', 'arm700i', 'arm710', 'arm710c', 'arm7100', 'arm720', 'arm7500', 'arm7500fe', 'arm7tdmi', 'arm7tdmi-s', 'arm710t', 'arm720t', 'arm740t', 'strongarm', 'strongarm110', 'strongarm1100', 'strongarm1110', 'arm8', 'arm810', 'arm9', 'arm9e', 'arm920', 'arm920t', 'arm922t', 'arm946e-s', 'arm966e-s', 'arm968e-s', 'arm926ej-s', 'arm940t', 'arm9tdmi', 'arm10tdmi', 'arm1020t', 'arm1026ej-s', 'arm10e', 'arm1020e', 'arm1022e', 'arm1136j-s', 'arm1136jf-s', 'mpcore', 'mpcorenovfp', 'arm1156t2-s', 'arm1156t2f-s', 'arm1176jz-s', 'arm1176jzf-s', 'cortex-a5', 'cortex-a7', 'cortex-a8', 'cortex-a9', 'cortex-a12', 'cortex-a15', 'cortex-a53', 'cortex-a57', 'cortex-a72', 'cortex-r4', 'cortex-r4f', 'cortex-r5', 'cortex-r7', 'cortex-m7', 'cortex-m4', 'cortex-m3', 'cortex-m1', 'cortex-m0', 'cortex-m0plus', 'cortex-m1.small-multiply', 'cortex-m0.small-multiply', 'cortex-m0plus.small-multiply', 'exynos-m1', 'marvell-pj4', 'xscale', 'iwmmxt', 'iwmmxt2', 'ep9312', 'fa526', 'fa626', 'fa606te', 'fa626te', 'fmp626', 'fa726te', 'xgene1', 'cortex-a15.cortex-a7', 'cortex-a57.cortex-a53', 'cortex-a72.cortex-a53')

-- Needs to use -mcpu= rather than -march=
-- If choosing cortex-a53, probably ought to issue -mfix-cortex-a53-843419 and -mfix-cortex-a53-835769
-- Also need to support +crypto, +fp, +crc features, perhaps via -march=armv8-a+crypto+fp+crc say
instructionSet('ARM (64-bit Little Endian)',                           'aarch64',       '',       true,  true , '-mcpu=',  'generic',        {}, 'generic', 'generic+crc', 'generic+crc+crypto', 'generic+crypto', 'cortex-a53’', 'cortex-a57', 'cortex-a72', 'exynos-m1', 'thunderx', 'xgene1')

instructionSet('ARM (64-bit Big Endian)',                              'aarch64_be',    '',       true,  false, '-mcpu=',  'generic',        {}, 'generic', 'generic+crc', 'generic+crc+crypto', 'generic+crypto', 'cortex-a53’', 'cortex-a57', 'cortex-a72', 'exynos-m1', 'thunderx', 'xgene1')

instructionSet('AVR (32-Bit Big Endian)',                              'avr32',         '',       false, false,  nil,      nil,              {})

-- '' => cris v10. There are others (older are v0, v3 and v8) but not viable AFAIK via tuple
instructionSet('CRIS (32-Bit Little Endian)'                           'cris',          '',       false, true , '-mcpu=',  'v32',            {v10 = '', v32 = 'v32'}, 'v0', 'v3', 'v8', 'v10', 'v32')

-- Elbrus
-- InstructionSet:new('Elbrus E2K', 'e2k', ????)

-- Fujitsu
instructionSet('FR-V (32-Bit Little Endian)'                           'frv',           '',       false, true , '-mcpu=',  'frv',            {}, 'frv', 'fr550', 'tomcat', 'fr500', 'fr450', 'fr405', 'fr400', 'fr300', 'simple' )

instructionSet('Hexagon (32-bit Little Endian)',                       'hexagon',       '',       false, true , nil,       nil               {})

instructionSet('IA-32',                                                'i',             '',       false, true , '-march=', 'i686',           {i386 = '386', i486 = '486', i586 = '586', i686 = '686'}, 'i386', 'i486', 'i586', 'pentium-mmx', 'pentiumpro', 'i686', 'pentium2', 'pentium3', 'pentium-m', 'pentium4', 'prescott', 'k6', 'k6-2', 'k6-3', 'athlon', 'athlon-4', 'winchip-c6', 'winchip2', 'c3', 'c3-2', 'geode')

-- Needs to use -mtune= rather than -mcpu=
instructionSet('IA-64',                                                'ia64',          '',       false, true , '-mtune=', 'itanium',        {}, 'itanium', 'itanium1', 'merced', 'itanium2', 'mckinley')

-- Not supported k1om (Xeon Phi)

-- Note, on Linux, uname -m does not include MIPS' 'el'..! So no easy way to tell endianness (experiment with Aboriginal Linux releases)
-- TODO: Missing lots of processors
-- TODO: Need to rework this in terms of o32, n32, o64, n64, etc
-- need to specify -march=X -mtune=X to get optimisation (not just -march=)
-- TODO: Specific processor types have been ommitted for now and need adding
-- TODO: Look at -mabi= 32 (is actually 'o32') / o64 / n32 (64-bit chips, 32-bit pointers) / 64 / eabi (32 and 64 bit)

instructionSet('MIPS (32-bit Little Endian)',                          'mipsel',        '',       false, true,  '-mcpu=',  'mips1',       {}, 'mips1', 'mips2', 'mips32', 'mips32r2', 'mips32r3', 'mips32r5', 'mips32r6')

instructionSet('MIPS (32-bit Big Endian)',                             'mips',          '',       false, false, '-mcpu=',  'mips1',       {}, 'mips1', 'mips2', 'mips32', 'mips32r2', 'mips32r3', 'mips32r5', 'mips32r6')

-- mips64el-unknown-linux-gnu
instructionSet('MIPS (64-bit Little Endian)',                          'mips64el',      '',       true,  true , '-mcpu=',  'mips3',       {}, 'mips3', 'mips4', 'mips64', 'mips64r2', 'mips64r3', 'mips64r5', 'mips64r6')

-- mips64-unknown-linux-gnu
instructionSet('MIPS (64-bit Big Endian)',                             'mips64',        '',       true,  false, '-mcpu=',  'mips3',       {}, 'mips3', 'mips4', 'mips64', 'mips64r2', 'mips64r3', 'mips64r5', 'mips64r6')

-- mips64el-unknown-linux-gnuabi64
instructionSet('MIPS (64-bit Little Endian) ABI64',                    'mips64el',      'abi64',  true,  true , '-mcpu=',  'mips3',       {}, 'mips3', 'mips4', 'mips64', 'mips64r2', 'mips64r3', 'mips64r5', 'mips64r6')

-- mips64-unknown-linux-gnuabi64
instructionSet('MIPS (64-bit Big Endian) ABI64',                       'mips64',        'abi64',  true,  false, '-mcpu=',  'mips3',       {}, 'mips3', 'mips4', 'mips64', 'mips64r2', 'mips64r3', 'mips64r5', 'mips64r6')

instructionSet('PA-RISC (64-Bit Big Endian)'                           'hppa',          '',       true,  false, '-march=', '2.0',         {['1.0'] = '1.0', ['1.1'] = '1.1', ['2.0'] = '2.0'}, '1.0', '1.1', '2.0')

-- m32r-unknown-linux-gnu
-- Annoyingly, CPU variants are only possible via switches, not --mcpu=; bi-endian, but not obvious how to switch
instructionSet('M32R',                                                 'm32r',          '',       false,  true, nil,        nil,          {})

-- Previous used tuple 'or32-'; current examples eg or1k-linux-musl
instructionSet('OpenRISC',                                             'or1k',          '',       false, false, nil,        nil,          {})

-- Unsure of which PowerPC -mcpu= these belong to: '505', '801', '821', '823', '860', '8540', 'a2'
-- need to specify -march=X -mtune=X to get optimisation (not just -march=)

instructionSet('PowerPC (32-bit Little Endian)',                       'powerpcle',     '',       false, false, '-mcpu=',  'powerpc',     {}, 'powerpc', '401', '403', '405', '405fp', '440', '440fp', '464', '464fp', '476', '476fp', '601', '602', '603', '603e', '604', '604e', '740',' 750', '7400', '7450', 'G3', 'G4', 'titan')

-- powerpc-linux-gnu AND powerpc-unknown-linux-gnu
instructionSet('PowerPC (32-bit Big Endian)',                          'powerpc',       '',       false, false, '-mcpu=',  'powerpc',     {}, 'powerpc', '401', '403', '405', '405fp', '440', '440fp', '464', '464fp', '476', '476fp', '601', '602', '603', '603e', '604', '604e', '740',' 750', '7400', '7450', 'G3', 'G4', 'titan')

-- e500 (MPC8500) and e200 (MPC5xx)  powerpc-linux-gnuspe
instructionSet('PowerPC Signal Processing Engine (32-bit Big Endian)', 'powerpc',       'spe',    false, false, '-mcpu=',  'powerpc',     {}, 'powerpc', 'e300c2', 'e300c3', 'e500mc', 'e500mc64', 'e5500', 'e6500', 'ec603e')

instructionSet('PowerPC (64-bit Little Endian)',                       'powerpc64le',    '',      false, false, '-mcpu=',  'powerpc64le', {}, 'powerpc64le', '620', '630', '970', 'G5', 'power3', 'power4', 'power5', 'power5+', 'power6', 'power6x', 'power7', 'power8', 'rs64')

instructionSet('PowerPC (64-bit Big Endian)',                          'powerpc64',      '',      false, false, '-mcpu=',  'powerpc64',   {}, 'powerpc64', '620', '630', '970', 'G5', 'power3', 'power4', 'power5', 'power5+', 'power6', 'power6x', 'power7', 'power8', 'rs64')


-- need to specify -march=X -mtune=X to get optimisation (not just -march=)

-- Not strictly true; z/Architecture is actually 31-bit
instructionSet('S/390 (31-bit Big Endian)',                            's390',           '',      false, false, '-march=', 'g5',          {}, 'g5', 'g6', 'z900', 'z990', 'z9-109', 'z9-ec', 'z10', 'z196', 'zEC12', 'z13')

instructionSet('S/390 (64-bit Big Endian)',                            's390x',          '',      true,  false, '-march=', 'z900',        {}, 'z900', 'z990', 'z9-109', 'z9-ec', 'z10', 'z196', 'zEC12', 'z13')


-- SH 2, 3, 4, 64 don't support -mcpu, etc (similar to Renesas M32R), so requiring explicit options


-- aka sparcv8
instructionSet('SPARC (32-bit Big Endian)',                            'sparc',          '',      false, false, '-mcpu=',  'v8',          {}, 'v7', 'cypress', 'leon3v7', 'v8', 'supersparc', 'hypersparc', 'leon', 'leon3', 'sparclite', 'f930', 'f934', 'sparclite86x', 'sparclet', 'tsc701')

-- aka sparc64, sparcv9
instructionSet('SPARC (64-bit Big Endian)',                            'sparc64',        '',      false, false, '-mcpu=',  'v9',          {}, 'v9', 'ultrasparc', 'ultrasparc3', 'niagara', 'niagara2', 'niagara3', 'niagara4')

-- Should also specify -mtune=X for best performance
-- I'm not 100% certain that selecting k8 is the right thing to do; unlike IA-32, there is no generic x86_64 target
instructionSet('x86_64',                                               'x86_64',         '',      true,  false, '-march=', 'k8',          {}, 'k8', 'k8-sse3', 'barcelona', 'bdver1', 'bdver2', 'bdver3', 'bdver4', 'btver1', 'btver2', 'nocona', 'core2', 'nehalem', 'westmere', 'sandybridge', 'ivybridge', 'haswell', 'broadwell', 'bonnell', 'silvermont', 'kn1')

-- Should also specify -mtune=X for best performance
-- eg x86_64-pc-linux-gnux32
instructionSet('x32',                                                  'x86_64',         'x32',   false, true , '-march=', 'k8',          {}, 'k8', 'k8-sse3', 'barcelona', 'bdver1', 'bdver2', 'bdver3', 'bdver4', 'btver1', 'btver2', 'nocona', 'core2', 'nehalem', 'westmere', 'sandybridge', 'ivybridge', 'haswell', 'broadwell', 'bonnell', 'silvermont', 'kn1')


-- Not supported: m68k, coldfire
-- sh64? sh? tile vax xtensa
