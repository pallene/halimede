--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local tabelize = halimede.table.tabelize


assert.globalTableHasChieldFieldOfTypeFunction('string', 'format')
local formatString = '([^%s]+)'
local function multisplitter(separators)
	assert.parameterTypeIsString('separators', separators)
	
	local pattern = formatString:format(separators)
	return function(value)
		assert.parameterTypeIsString('value', value)
	
		local fields = tabelize()
	
		value:gsub(pattern, function(field)
			fields:insert(field)
		end)
	
		return fields
	end
end

modulefunction(function(self, separators)
	return multisplitter(separators)
end)
