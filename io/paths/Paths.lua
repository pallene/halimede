--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Paths = moduleclass('Paths')

local tabelize = require('halimede.table.tabelize').tabelize
local halimede = require('halimede')
local assert = halimede.assert
local Path = requireSibling('Path')


assert.globalTypeIsFunction('ipairs')
function module:initialize(pathStyle, paths)
	assert.parameterTypeIsInstanceOf(pathStyle, PathStyle)
	assert.parameterTypeIsTable(pathObjects)
	
	for _, path in ipairs(paths) do
		assert.parameterTypeIsInstanceOf(path, Path)
	end
	
	self.pathStyle = pathStyle
	self.paths = paths
end

function module:formatPaths(specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsBoolean(specifyCurrentDirectoryExplicitlyIfAppropriate)
	
	local pathsBuffer = tabelize()
	for path in self:iterate() do
		pathsBuffer:insert(path:formatPath(specifyCurrentDirectoryExplicitlyIfAppropriate))
	end
	return pathsBuffer:concat(self.pathStyle.pathSeparator)
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