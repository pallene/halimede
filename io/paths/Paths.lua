--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Paths = moduleclass('Paths')

local tabelize = require('halimede.table.tabelize').tabelize
local halimede = require('halimede')
local assert = halimede.assert
local AbstractPath = requireSibling('AbstractPath')
local shellLanguage = require('halimede.io.shellScript.ShellLanguage').Default


Paths.static.pathSeparator = shellLanguage.pathSeparator

assert.globalTypeIsFunction('ipairs')
function module:initialize(pathSeparator, pathObjects)
	assert.parameterTypeIsString(pathSeparator)
	assert.parameterTypeIsTable(pathObjects)
	
	for _, pathObject in ipairs(pathObjects) do
		assert.parameterTypeIsInstanceOf(pathObject, AbstractPath)
	end
	
	self.pathSeparator = pathSeparator
	self.pathObjects = pathObjects
	self.paths = pathObjects:concat(pathSeparator)
end

function module:iterate()
	local index = 0
	local count = #self.pathObjects
	return function()
		index = index + 1
		if index > count then
			return nil
		end
		return self.pathObjects[index]
	end
end