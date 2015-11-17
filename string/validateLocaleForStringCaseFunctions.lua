--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local type = halimede.type
local exception = require('halimede.exception')


if type.hasPackageChildFieldOfTypeFunctionOrCall('os', 'setlocale') then
	local function currentLocaleShouldBe(category, shouldBe)
		assert.parameterTypeIsString(category)
		assert.parameterTypeIsString(shouldBe)
		
		local is = os.setlocale('nil', category)
		if is ~= nil and is ~= shouldBe then
			exception.throw("The OS locale category '%s' must be set to '%s' so that string.tolower and string.toupper can be used reliably", category, shouldBe)
		end
	end
else
	local function currentLocaleShouldBe(category, shouldBe)
	end
end

local function validateLocale()
	currentLocaleShouldBe('all', 'C')
	currentLocaleShouldBe('ctype', 'C')
	currentLocaleShouldBe('collate', 'C')
end
validateLocale()
