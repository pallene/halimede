This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local class = require('middleclass')
local Object = class.Object
local tabelize = require('halimede.table.tabelize').tabelize
local halimede = require('halimede')
local assert = halimede.assert
local AbstractPath = requireSibling('AbstractPath')


local Paths = class('Paths')

Paths.static.pathSeparator = halimede.packageConfiguration.pathSeparator

assert.globalTypeIsFunction('ipairs')
function Paths:initialize(...)
	local pathInstances = tabelize({...})
	for _, pathInstance in ipairs(pathInstances) do
		assert.parameterTypeIsInstanceOf(pathInstance, AbstractPath)
	end
	
	self.pathInstances = pathInstances
	self.paths = pathInstances:concat(Paths.pathSeparator)
end

return Paths
