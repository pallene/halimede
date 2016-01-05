--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local class = halimede.class


assert.globalTypeIsFunctionOrCall('ipairs')
function module.stringEnumerationClass(className, ...)
	assert.parameterTypeIsString('className', className)

	local Class = class(className)

	Class.initialize = function(self, instanceName, index, value)
		self.index = index
		self.value = value

		Class.static[instanceName] = self
	end

	for index, value in ipairs({...}) do
		assert.parameterTypeIsString('value', value)

		Class:new(value, index, value)
	end

	return Class
end

function module.numberEnumerationClass(className, ...)
	assert.parameterTypeIsString('className', className)

	local Class = class(className)

	Class.initialize = function(self, instanceName, index, value)
		self.index = index
		self.value = value

		Class.static[instanceName] = self
	end

	for index, instanceNameValuePair in ipairs({...}) do
		assert.parameterTypeIsTable('instanceNameValuePair', instanceNameValuePair)

		local instanceName = instanceNameValuePair[1]
		assert.parameterTypeIsString('instanceName', instanceName)

		local value = instanceNameValuePair[2]
		assert.parameterTypeIsNumber('value', value)

		Class:new(instanceName, index, value)
	end

	return Class

end
