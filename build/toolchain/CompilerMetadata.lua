--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local CompilerMetadata = moduleclass('CompilerMetadata')

local CompilerName = requireSibling('CompilerName')
local gcc = CompilerName.gcc
local gxx = CompilerName['g++']
local clang = CompilerName.clang
local clangxx = CompilerName['clang++']


function CompilerMetadata:initialize(compilerName, version, supportsC, supportsCPlusPlus)
	assert.parameterTypeIsInstanceOf('compilerName', compilerName, CompilerName)
	assert.parameterTypeIsString('version', version)
	assert.parameterTypeIsBoolean('supportsC', supportsC)
	assert.parameterTypeIsBoolean('supportsCPlusPlus', supportsCPlusPlus)
	
	self.compilerName = compilerName
	self.version = version
	self.supportsC = supportsC
	self.supportsCPlusPlus = supportsCPlusPlus
	
	local name = compilerName.value
	self.name = name
	CompilerMetadata.static[name .. ' ' .. version] = self
end

CompilerMetadata:new(gcc, '4.9', true, false)
CompilerMetadata:new(gxx, '4.9', false, true)
CompilerMetadata:new(clang, '3.4', true, false)
CompilerMetadata:new(clangxx, '3.4', false, true)
