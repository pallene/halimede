--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception
local utf8CodePointInString = halimede.string.utf8CodePointInString


halimede.modulefunction(function(value, callback)
	
	local index = 1
	local byteLength = #value
	
	while index <= byteLength do
		
		local sizeOfCodePoint, codePoint = utf8CodePointInString(value, index)
		callback(value, index, sizeOfCodePoint, codePoint)
		
		index = index + sizeOfCodePoint
	end
	
end)
