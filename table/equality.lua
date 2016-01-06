--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local isNotTable = halimede.type.isNotTable
local isInstanceOf = halimede.class.Object.isInstanceOf


local function isUnequalWithNil(left, right)
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
module.isUnequalWithNil = isUnequalWithNil

assert.globalTypeIsFunctionOrCall('ipairs')
local function isArrayShallowUnequal(left, right)
	if isNotTable(left) then
		return false
	end

	if isNotTable(right) then
		return false
	end

	if #left ~= #right then
		return true
	end

	for index, leftItem in ipairs(left) do
		if right[index] ~= leftItem then
			return true
		end
	end

	return false
end
module.isArrayShallowUnequal = isArrayShallowUnequal

local function isClassUnequal(left, right)
	if right == nil then
		return true
	end
	return not isInstanceOf(right, left.class)
end
module.isClassUnequal = isClassUnequal

-- Does not support arrays of arrays
assert.globalTypeIsFunctionOrCall('ipairs')
function module.areInstancesEqual(left, right, simpleEqualityFieldNames, shallowArrayFieldNames, potentiallyNilFieldNames)
	if isClassUnequal(left, right) then
		return false
	end

	for _, simpleEqualityFieldName in ipairs(simpleEqualityFieldNames) do
		if left[simpleEqualityFieldName] ~= right[simpleEqualityFieldName] then
			return false
		end
	end

	for _, potentiallyNilFieldName in ipairs(potentiallyNilFieldNames) do
		if isUnequalWithNil(left[potentiallyNilFieldName], right[potentiallyNilFieldName]) then
			return false
		end
	end

	for _, shallowArrayFieldName in ipairs(shallowArrayFieldNames) do
		if isArrayShallowUnequal(left[shallowArrayFieldName], right[shallowArrayFieldName]) then
			return false
		end
	end

	return true
end
