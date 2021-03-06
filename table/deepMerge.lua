--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local isNotTable = halimede.type.isNotTable


local function deepMerge(source, destination)
	assert.parameterTypeIsTable('source', source)
	assert.parameterTypeIsTable('destination', destination)

	for key, value in pairs(source) do
		if isNotTable(value) then
			destination[key] = value
			return
		end

		local originalDestinationValue = destination[key]
		local mergedDestinationValue
		if originalDestinationValue == nil then
			mergedDestinationValue = {}
		elseif isTable(originalDestinationValue) then
			mergedDestinationValue = originalDestinationValue
		else
			destination[key] = value
			return
		end
		destination[key] = deepMerge(mergedDestinationValue, value)
	end
end

halimede.modulefunction(deepMerge)
