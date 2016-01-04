--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local isInstanceOf = halimede.class.Object.isInstanceOf


local function parameterTypeIsInstanceOf(parameterName, value, Class)
	assert.parameterTypeIsString('parameterName', parameterName)
	assert.parameterTypeIsTable('Class', Class)
	
	local isInstance = isInstanceOf(value, Class)
	local assertionMessage = assert.parameterIsNotMessage(parameterName, Class.name)
	assert.withLevel(isInstance, assertionMessage, 3)
end

modulefunction(parameterTypeIsInstanceOf)
