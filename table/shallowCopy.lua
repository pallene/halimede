--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local isNotTable = halimede.type.isNotTable


assert.globalTypeIsFunctionOrCall('setmetatable', 'getmetatable', 'next')
local function shallowCopy(original)
	if isNotTable(original) then
		return original
	end

	local copy = {}

	for key, value in next, original do
		copy[key] = value
	end
	setmetatable(copy, getmetatable(original))

	return copy
end

halimede.modulefunction(shallowCopy)
