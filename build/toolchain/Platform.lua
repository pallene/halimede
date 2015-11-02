--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('halimede.middleclass')
local CompilerMetadata = requireSibling('CompilerMetadata')


local Platform = class('Platform')

-- TODO: Mac OS X / Brew, sysroot, etc
function Platform:initialize(name, gnuTuple, cCompilerDriver, cPlusPlusCompilerDriver)
	assert.parameterTypeIsString(name)
	assert.parameterTypeIsInstanceOf(gnuTuple, GnuTuple)
	assert.parameterTypeIsInstanceOf(cCompilerDriver, CompilerDriver)
	assert.parameterTypeIsInstanceOf(cPlusPlusCompilerDriver, CompilerDriver)
	
	self.name = name
	self.gnuTuple = gnuTuple
	self.cCompilerDriver = cCompilerDriver
	self.cPlusPlusCompilerDriver = cPlusPlusCompilerDriver
end
