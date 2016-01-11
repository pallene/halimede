--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractDefineValue = halimede.build.defines.defineValues.AbstractDefineValue


halimede.moduleclass('EnumerationDefineValue', AbstractDefineValue)

function module:initialize(enumeratedConstant, enumerationClass)
	assert.parameterTypeIsTable('enumerationClass', enumerationClass)
	assert.parameterTypeIsInstanceOf('enumeratedConstant', enumeratedConstant, enumerationClass)
	
	AbstractDefineValue.initialize(self)
	
	self.enumeratedConstant = enumeratedConstant
end

function module:_appendToCompilerDriverArguments(defineName, compilerDriverArguments)
	compilerDriverArguments:definePreprocessorMacro(defineName, self.enumeratedConstant.value)
end
