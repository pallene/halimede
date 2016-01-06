--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local parameterIsNotMessage = assert.parameterIsNotMessage
local withLevel = assert.withLevel
local isInstanceOf = halimede.class.Object.isInstanceOf


local function parameterTypeIsInstanceOf(parameterName, value, Class)
	assert.parameterTypeIsString('parameterName', parameterName)
	assert.parameterTypeIsTable('Class', Class)

	local isInstance = isInstanceOf(value, Class)
	if not isInstance then
		local assertionMessage = parameterIsNotMessage(parameterName, Class.name)
		withLevel(assertionMessage, 3)
	end
end

halimede.modulefunction(parameterTypeIsInstanceOf)
