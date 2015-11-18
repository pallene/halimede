--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local FilePaths = moduleclass('FilePaths')

local tabelize = require('halimede.table.tabelize').tabelize
local halimede = require('halimede')
local assert = halimede.assert
local Path = requireSibling('Path')


assert.globalTypeIsFunction('ipairs')
function module:initialize(paths)
	assert.parameterTypeIsTable(paths)
	
	for _, path in ipairs(paths) do
		assert.parameterTypeIsInstanceOf(path, Path)
		path:assertIsFilePath('path')
	end
	
	self.paths = paths
end

assert.globalTypeIsFunction('ipairs')
assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert')
function module:appendFileExtension(fileExtension)
	assert.parameterTypeIsString(fileExtension)

	local copy = {}
	
	for _, path in ipairs(self.paths) do
		table.insert(copy, path:appendFileExtension(fileExtension))
	end
	
	return FilePaths:new(copy)
end

function module:toCFiles()
	return self:appendFileExtension('c')
end

function module:toCxxFiles()
	return self:appendFileExtension('cxx')
end

assert.globalTypeIsFunction('ipairs')
assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert')
function module:toFileNamePaths()
	local copy = {}
	
	for _, path in ipairs(self.paths) do
		table.insert(copy, path:finalPathElementName())
	end
	
	return FilePaths:new(copy)
end

function module:toObjectsWithoutPaths(objectFileExtension)
	assert.parameterTypeIsString(objectFileExtension)
	
	return self:toFileNamePaths():appendFileExtension(objectFileExtension)
end

function module:iterate()
	local index = 0
	local count = #self.paths
	return function()
		index = index + 1
		if index > count then
			return nil
		end
		return self.paths[index]
	end
end