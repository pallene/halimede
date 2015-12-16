--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local tabelize = halimede.table.tabelize
local Path = halimede.io.paths.Path


local FilePaths = moduleclass('FilePaths')

assert.globalTypeIsFunctionOrCall('ipairs')
function module:initialize(paths)
	assert.parameterTypeIsTable('paths', paths)
	
	for _, path in ipairs(paths) do
		assert.parameterTypeIsInstanceOf('path', path, Path)
		path:assertIsFilePath('path')
	end
	
	self.paths = paths
end

assert.globalTypeIsFunctionOrCall('ipairs')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('table', 'insert')
function module:appendFileExtension(fileExtension)
	assert.parameterTypeIsString('fileExtension', fileExtension)

	local copy = {}
	
	for _, path in ipairs(self.paths) do
		table.insert(copy, path:appendFileExtension(fileExtension))
	end
	
	return FilePaths:new(copy)
end

assert.globalTypeIsFunctionOrCall('ipairs')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('table', 'insert')
function module:toFileNamePaths()
	local copy = {}
	
	for _, path in ipairs(self.paths) do
		table.insert(copy, path:finalPathElementNameAsPath())
	end
	
	return FilePaths:new(copy)
end

assert.globalTypeIsFunctionOrCall('ipairs', 'pairs')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('table', 'insert')
function module:withoutFileNames()
	local copy = {}
	
	for _, path in ipairs(self.paths) do
		local newPath = path:strippedOfFinalPathElement()
		copy[newPath:toString(true)] = newPath
	end

	local set = {}
	for _, path in pairs(copy) do
		table.insert(set, path)
	end
	
	return set
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

-- function module:toCFiles()
-- 	return self:appendFileExtension('c')
-- end
--
-- function module:toCxxFiles()
-- 	return self:appendFileExtension('cxx')
-- end
--
-- function module:toObjectsWithoutPaths(objectFileExtension)
-- 	assert.parameterTypeIsString('objectFileExtension', objectFileExtension)
--
-- 	return self:toFileNamePaths():appendFileExtension(objectFileExtension)
-- end