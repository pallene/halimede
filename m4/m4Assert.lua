--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local withLevel = assert.withLevel
local parameterIsNotMessage = assert.parameterIsNotMessage
local isString = halimede.type.isString


local isMissing = halimede.createNamedCallableFunction('isMissing', function(value)
	return value == nil
end)
module.isMissing = isMissing

local Void = {}
module.Void = Void

local isVoid = halimede.createNamedCallableFunction('isVoid', function(value)
	return value == Void
end)
module.isVoid = isVoid

local isMissingOrVoid = halimede.createNamedCallableFunction(functionName, function(value)
	return value == nil or value == Void
end)
module.isMissingOrVoid = isMissingOrVoid

function module.parameterTypeIsMissingOrIsVoidOrIsString(parameterName, value)
	assert.parameterTypeIsString(parameterName)

	if isMissingOrVoid(value) then
		return
	end

	if isString(value) then
		return
	end

	withLevel(parameterIsNotMessage(parameterName, 'missing (nil), void or string'), 2)
end
