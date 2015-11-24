--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


-- Similar to halimede.createNamedCallableFunction, but has to work on existing module
assert.globalTypeIsFunction('getmetatable')
function modulefunction(functor)
	local metatable = getmetatable(module)
	metatable.__call = functor
	metatable.__tostring = function()
		return 'modulefunction ' .. functionName
	end
	module.functor = function(...)
		return functor(module, ...)
	end
	return module
end
