--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


moduleclass('ToolchainPaths')
local AbsolutePath = require('halimede.io.paths.AbsolutePath')
local RelativePath = require('halimede.io.paths.RelativePath')

local halimede = require('halimede')
local assert = halimede.assert
local exception = require('halimede.exception')


function module.pathConstant(prefixPath, versionRelativePath, ...)
	local folderPath = RelativePath:new(prefixPath.folderSeparator, ...)
	local relativePath = folderPath
	local absolutePath = prefixPath:appendRelativePathOf(relativePath)
	
	return absolutePath, relativePath
end
	
-- eg returns '/opt/package/version/dependencies/bin' if prefixPath == '/opt'
function module.pathVersioned(prefixPath, versionRelativePath, ...)
	local folderPath = RelativePath:new(prefixPath.folderSeparator, ...)
	local relativePath = folderPath:appendRelativePathOf(versionRelativePath)
	local absolutePath = prefixPath:appendRelativePathOf(relativePath)
	
	return absolutePath, relativePath
end
	
-- eg returns '/bin/package/version/dependencies' if prefixPath == '/' and folderName == 'bin'
function module.pathInsidePackage(prefixPath, versionRelativePath, ...)
	local folderPath = RelativePath:new(prefixPath.folderSeparator, ...)
	local relativePath = versionRelativePath:appendRelativePathOf(folderPath)
	local absolutePath = prefixPath:appendRelativePathOf(relativePath)
	
	return absolutePath, relativePath
end
