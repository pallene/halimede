--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('halimede.middleclass')
local Platform = requireSibling('Platform')
local CompilerDriver = requireSibling('CompilerDriver')
local GnuTuple = requireSibling('GnuTuple')


local Toolchain = class('Toolchain')

-- Maybe replace compilerDriver with a 'platform'
-- http://wiki.osdev.org/Target_Triplet
-- We use build for the build platform, and host platform for the platform compiled code will run on (host == target)
function Toochain:initialize(name, crossPlatform, buildPlatform)
	assert.parameterTypeIsString(name)
	assert.parameterTypeIsInstanceOf(crossPlatform, Platform)
	
	self.name = name
	self.crossPlatform = crossPlatform
	
	if buildPlatform == nil then
		self.buildPlatform = crossPlatform
		self.isCrossCompiling = false
	else
		assert.parameterTypeIsInstanceOf(buildPlatform, Platform)
		self.buildPlatform = buildPlatform
		self.isCrossCompiling = true
	end
	
end


Toolchain.MacOsXMavericks = Toolchain:new(
	'Mac OS X Mavericks Homebrew with GCC 4.9 C and C++ compiler',
	Platform:new(
		'Mac OS X Mavericks Homebrew',
		GnuTuple['x86_64-apple-darwin13.4.0'],
		CompilerDriver.gcc49_systemNativeHostX86_64,
		CompilerDriver.gccxx49_systemNativeHostX86_64
	)
)

Toolchain.MacOsXYosemite = Toolchain:new(
	'Mac OS X Yosemite Homebrew with GCC 4.9 C and C++ compiler',
	Platform:new(
		'Mac OS X Yosemite Homebrew',
		GnuTuple['x86_64-apple-darwin14'],
		CompilerDriver.gcc49_systemNativeHostX86_64,
		CompilerDriver.gccxx49_systemNativeHostX86_64
	)
)

return Toolchain
