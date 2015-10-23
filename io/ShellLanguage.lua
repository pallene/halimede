--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local assert = require('halimede.assert')
local tabelize = require('halimede.tabelize').tabelize


assert.globalTableHasChieldFieldOfTypeFunction('string', 'gsub')
module.POSIX = {
	toShellCommand = function(...)
		local arguments = {...}
	
		local commandBuffer = tabelize()
	
	
		-- Windows: add  "type NUL && "
	
		for _, argument in ipairs(arguments) do
			assert.parameterTypeIsString(argument)
			commandBuffer:insert("'" .. argument:gsub("'", "''") .. "'")
		end
	
		local command = commandBuffer:concat(' ')
		return command
	end
}

module.Windows = {
	toShellCommand = function(...)
		
	end
}
