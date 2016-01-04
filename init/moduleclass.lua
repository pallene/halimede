--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
assert.globalTypeIsFunctionOrCall('pairs', 'setmetatable', 'getmetatable')
function moduleclass(...)
	local newClass = halimede.class(...)
	
	local moduleClass = module
	for key, value in pairs(newClass) do
		moduleClass[key] = newClass[key]
	end
	
	setmetatable(moduleClass, getmetatable(newClass))
	
	return moduleClass
end
