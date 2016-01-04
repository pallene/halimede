--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local isTable = type.isTable


function module.isUnequalWithNil(left, right)
	if (left == nil or right == nil) then
		if left == nil and right ~= nil then
			return true
		end
		if left ~= nil and right == nil then
			return true
		end
	elseif left ~= right then
		return true
	end
	return false
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module.isArrayShallowUnequal(left, right)
	if not isTable(left) then
		return false
	end
	
	if not isTable(right) then
		return false
	end
	
	if #left ~= #right then
		return true
	end
	
	for index, leftItem in ipairs(left) do
		if right[index] ~= left then
			return true
		end
	end
	
	return false
end
