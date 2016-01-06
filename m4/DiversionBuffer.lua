--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert


halimede.moduleclass('DiversionBuffer')

function module:initialize(number)
	assert:parameterTypeIsPositiveInteger(number)

	self.number = number
	self.value = ''
end

function module:append(contents)
	assert.parameterTypeIsString(contents)

	self.value = self.value .. contents
end

function module:flush()
	local contents = self.value
	self.value = ''
	return contents
end

function module:__eq(right)
	return self.number == right.number
end

function module:__lt(right)
	return self.number < right.number
end

function module:__le(right)
	return self.number <= right.number
end
