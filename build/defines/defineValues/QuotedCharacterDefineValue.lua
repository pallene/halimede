--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractSimpleDefineValue = halimede.build.defines.defineValues.AbstractSimpleDefineValue
local exception = halimede.exception


halimede.moduleclass('QuotedCharacterDefineValue', AbstractSimpleDefineValue)

function module:initialize(character)
	assert.parameterTypeIsString('character', character)
	
	if #character ~= 1 then
		exception.throw("character '%s' is not exactly one character", character)
	end
	
	AbstractSimpleDefineValue.initialize(self, "'" .. character .. "'")
end
