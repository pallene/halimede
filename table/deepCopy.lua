--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


require('halimede')
local isTable = type.isTable


assert.globalTypeIsFunctionOrCall('setmetatable', 'getmetatable', 'next')
local function deepCopyWithState(original, encountered)
	if not isTable(original) then
		return original
	end

	local alreadyCopied = encountered[original]
	if alreadyCopied then
		return alreadyCopied
	end

	local copy = {}
	for key, value in next, original do
		copy[deepCopyWithState(key, encountered)] = deepCopyWithState(value, encountered)
	end
	setmetatable(copy, deepCopyWithState(getmetatable(original), encountered))

	encountered[original] = copy
	return copy
end

local function deepCopy(original)
	return deepCopyWithState(original, {})
end

halimede.modulefunction(deepCopy)
