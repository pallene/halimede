--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
assert.globalTypeIsFunctionOrCall('ipairs', 'tostring', 'unpack')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'format')
local function format(template, ...)
	assert.parameterTypeIsString('template', template)
	
	local formatArguments = {...}
	for index, formatArgument in ipairs(formatArguments) do
		formatArguments[index] = tostring(formatArgument)
	end
	return template:format(unpack(formatArguments))
end

modulefunction(format)
