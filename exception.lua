--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local assert = require('halimede').assert
local type = require('halimede').type


assert.globalTypeIsFunction('unpack', 'ipairs', 'tostring')
assert.globalTableHasChieldFieldOfTypeFunction('string', 'format')
function module.throwWithLevelIncrement(levelIncrement, template, ...)
	assert.parameterTypeIsString(template)
	
	local formatArguments = {...}
	for index, formatArgument in ipairs(formatArguments) do
		if type.isObject(formatArgument) then
			formatArguments[index] = tostring(formatArgument)
		end
	end
	
	error(template:format(unpack(formatArguments)), 2 + levelIncrement)
end
local throwWithLevelIncrement = module.throwWithLevelIncrement

function module.throw(template, ...)
	assert.parameterTypeIsString(template)
	
	return throwWithLevelIncrement(1, template, ...)
end
