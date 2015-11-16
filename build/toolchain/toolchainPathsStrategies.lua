--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Path = require('halimede.io.paths.Path')

local halimede = require('halimede')
local assert = halimede.assert


function module.pathConstant(prefixPath, versionRelativePath, ...)
	assert.parameterTypeIsInstanceOf(prefixPath, Path)
	assert.parameterTypeIsInstanceOf(versionRelativePath, Path)
	
	local folderPath = prefixPath:newFromTemplate(...)
	
	local relativePath = folderPath
	local absolutePath = prefixPath:appendRelativePath(relativePath)
	
	return absolutePath, relativePath
end
	
-- eg returns '/opt/package/version/dependencies/bin' if prefixPath == '/opt'
function module.pathVersioned(prefixPath, versionRelativePath, ...)
	assert.parameterTypeIsInstanceOf(prefixPath, Path)
	assert.parameterTypeIsInstanceOf(versionRelativePath, Path)
	
	local folderPath = prefixPath:newFromTemplate(...)
	
	local relativePath = folderPath:appendRelativePath(versionRelativePath)
	local absolutePath = prefixPath:appendRelativePath(relativePath)
	
	return absolutePath, relativePath
end
	
-- eg returns '/bin/package/version/dependencies' if prefixPath == '/' and folderName == 'bin'
function module.pathInsidePackage(prefixPath, versionRelativePath, ...)
	assert.parameterTypeIsInstanceOf(prefixPath, Path)
	assert.parameterTypeIsInstanceOf(versionRelativePath, Path)
	
	local folderPath = prefixPath:newFromTemplate(...)
	
	local relativePath = versionRelativePath:appendRelativePath(folderPath)
	local absolutePath = prefixPath:appendRelativePath(relativePath)
	
	return absolutePath, relativePath
end
