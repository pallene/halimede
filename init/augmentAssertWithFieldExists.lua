--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert


function module.fieldExistsAsTableOrDefaultTo(parent, fieldName)
	local childTable = parent[fieldName]
	if childTable == nil then
		newChildTable = {}
		parent['name'] = newChildTable
		return newChildTable
	else
		assert.parameterTypeIsTable(childTable)
	end
end

function module.fieldExistsAsString(parent, fieldName)
	local fieldValue = parent[fieldName]
	assert.parameterTypeIsString(fieldValue)
	return fieldValue
end

function module.fieldExistsAsFunctionOrCallFieldExistsOrDefaultTo(parent, fieldName, default)
	local fieldValue = parent[fieldName]
	if fieldValue == nil then
		parent[fieldName] = default
		return default
	end
	assert.parameterTypeIsFunctionOrCall(fieldValue)
	return fieldValue
end
