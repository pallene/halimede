--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local type = require('halimede').type
local assert = halimede.assert

-- Now we have a working require, we can augment assert to work with middleclass' class system
local class = require('halimede.middleclass')
local Object = class.Object

assert.globalTypeIsFunction('tostring')
function assert.parameterTypeIsInstanceOf(value, Class)
	if not Object.isInstanceOf(value, Class) then
		assert.withLevel(isOfType(value), parameterIsNotMessage(tostring(Class)), 3)
	end
end
