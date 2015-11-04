--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Arguments = moduleclass('Arguments')

local halimede = require('halimede')
local assert = halimede.assert
local type = halimede.type
local tabelize = require('halimede.table.tabelize').tabelize


function Arguments:initialize()
	self.arguments = tabelize()
end

function Arguments:_append(argument)
	assert.parameterTypeIsString(argument)
	self.arguments:insert(argument)
end

assert.globalTypeIsFunction('ipairs')
function Arguments:append(...)
	local arguments = {...}
	for _, argument in ipairs(arguments) do
		if type.isTable(argument)
			for _, actualArgument in ipairs(argument) do
				self:_append(actualArgument)
			end
		else
			self:_append(argument)
		end
	end
end

assert.globalTypeIsFunction('unpack')
function Arguments:useUnpacked(userFunction)
	assert.parameterTypeIsFunctionOrCall(userFunction)
	
	return userFunction(unpack(self.arguments))
end