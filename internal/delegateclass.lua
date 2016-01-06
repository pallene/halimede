--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local isFunctionOrCall = halimede.type.isFunctionOrCall


assert.globalTypeIsFunctionOrCall('getmetatable', 'unpack')
local function delegate(class, fieldName)
	assert.parameterTypeIsTable('class', class)
	assert.parameterTypeIsNotNil('fieldName', fieldName)

	class.setInstanceMissingIndex(function(instance, key)

		local delegatedInstance = instance[fieldName]

		local underlyingMethodOrField = delegatedInstance[key]
		if isFunctionOrCall(underlyingMethodOrField) then
			return function(self, ...)
				-- Were we called MyInstance:MissingInstanceMethod() (if) or MyInstance.MissingInstanceMethod() (else)?
				-- Not perfect; fails if any method takes itself as a second argument (eg a comparison function)
				if self == instance then
					return underlyingMethodOrField(delegatedInstance, ...)
				else
					return underlyingMethodOrField(delegatedInstance, self, ...)
				end
			end
		else
			return underlyingMethodOrField
		end
	end)

	return class
end

local function delegateclass(className, fieldName, ...)
	local class = halimede.moduleclass(className, ...)
	return delegate(class, fieldName)
end
halimede.delegateclass = delegateclass
