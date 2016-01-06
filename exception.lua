--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local format = halimede.string.format


assert.globalTypeIsFunctionOrCall('unpack', 'ipairs', 'tostring')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'format')
function module.throwWithLevelIncrement(levelIncrement, template, ...)
	assert.parameterTypeIsPositiveInteger('levelIncrement', levelIncrement)
	assert.parameterTypeIsString('template', template)

	local message = format(template, ...)

	error(message, 2 + levelIncrement)
end
local throwWithLevelIncrement = module.throwWithLevelIncrement

function module.throw(template, ...)
	assert.parameterTypeIsString('template', template)

	return throwWithLevelIncrement(1, template, ...)
end
