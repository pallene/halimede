--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert


-- Adds the table.concat, table.insert, etc methods to optionalValueToTabelize, or returns an empty table with them added
assert.globalTypeIsTable('table')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('table', 'concat', 'insert', 'remove', 'sort')
assert.globalTypeIsFunctionOrCall('setmetatable')
local function tabelize(optionalValueToTabelize)
	assert.parameterTypeIsTableOrNil('optionalValueToTabelize', optionalValueToTabelize)

	local valueToTabelize = optionalValueToTabelize or {}

	return setmetatable(valueToTabelize, {__index = table})
end

halimede.modulefunction(tabelize)
