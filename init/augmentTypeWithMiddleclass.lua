--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local type = require('halimede').type
local class = require('halimede.middleclass')
local Object = class.Object


assertModule.globalTypeIsFunction('ipairs')
local function simpleTypeObject(name)
	return NamedFunction(name, function(...)
		local values = {...}
		for _, value in ipairs(values) do
			if Object.isInstanceOf(value, Object) then
				return true
			end
		end
		return false
	end)
end
type.isObject = simpleTypeObject(name)
