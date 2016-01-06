--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert


assert.globalTypeIsFunctionOrCall('ipairs')
local function unique(...)

	-- This is an exceedingly naive implementation (and thus very inefficient) which behaves as a linked set
	-- It is probably preferable to use the Sano library's LinkedSet

	local linkedSet = {}
	for _, array in {...} do
		assert.parameterTypeIsTable('array', array)

		for _, instance in ipairs(array) do
			local add = true
			for _, alreadyExtantInstance in ipairs(linkedSet) do
				if alreadyExtantInstance == instance then
					add = false
					break
				end
			end
			if add then
				linkedSet:insert(instance)
			end
		end
	end

	return linkedSet
end

halimede.modulefunction(unique)
