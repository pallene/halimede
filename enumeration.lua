--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local class = require('halimede.middleclass')
local halimede = require('halimede')
local assert = halimede.assert


assert.globalTypeIsFunction('ipairs')
function module:stringEnumerationClass(name, ...)
	assert.parameterTypeIsString(name)
	
	local Class = class(name)
	
	function Class:initialize(index, value)
		self.index = index
		self.value = value	
	end
	
	for index, constant in ipairs({...}) do
		assert.parameterTypeIsString(constant)
		Class.static[constant] = Class:new(index, constant)
	end
	
	return Class
end

function module:numberEnumerationClass(name, ...)

	assert.parameterTypeIsString(name)
	
	local Class = class(name)
	
	function Class:initialize(index, value)
		self.index = index
		self.value = value	
	end
	
	for index, nameValuePair in ipairs({...}) do
		assert.parameterTypeIsTable(nameValuePair)
		
		local name = nameValuePair[1]
		local value = nameValuePair[2]
		Class.static[name] = Class:new(index, value)
	end
	
	return Class
	
end