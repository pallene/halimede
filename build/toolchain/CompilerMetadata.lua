--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local CompilerMetadata = moduleclass('CompilerMetadata')

local halimede = require('halimede')
local assert = halimede.assert
local CompilerName = requireSibling('CompilerName')
local gcc = CompilerName.gcc
local gxx = CompilerName['g++']
local clang = CompilerName.clang
local clangxx = CompilerName['clang++']


function CompilerMetadata:initialize(unifiedName, name, version, supportsC, supportsCPlusPlus)
	assert.parameterTypeIsInstanceOf(name, CompilerName)
	assert.parameterTypeIsString(version)
	assert.parameterTypeIsBoolean(supportsC)
	assert.parameterTypeIsBoolean(supportsCPlusPlus)
	
	self.name = name
	self.version = version
	self.supportsC = supportsC
	self.supportsCPlusPlus = supportsCPlusPlus
	
	CompilerMetadata.static[name .. ' ' .. version] = self
end

CompilerMetadata:new(gcc, '4.9', true, false)
CompilerMetadata:new(gxx, '4.9', false, true)
CompilerMetadata:new(clang, '3.4', true, false)
CompilerMetadata:new(clangxx, '3.4', false, true)