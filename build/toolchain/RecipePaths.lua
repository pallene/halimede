--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local tabelize = halimede.table.tabelize
local exception = halimede.exception
local Platform = require.sibling('Platform')
local PlatformPaths = require.sibling('PlatformPaths')
local FilePaths = require.sibling('FilePaths')
local validatePath = require.sibling('PlatformPaths').validatePath


moduleclass('RecipePaths')

function module:initialize(platform, platformPaths, versionRelativePathElements)
	assert.parameterTypeIsInstanceOf('platform', platform, Platform)
	assert.parameterTypeIsInstanceOf('platformPaths', platformPaths, PlatformPaths)
	assert.parameterTypeIsTable('versionRelativePathElements', versionRelativePathElements)

	validatePath(versionRelativePath, 'versionRelativePath', 'isRelative')
	
	self.platform = platform
	self.platformPaths = platformPaths
	self.versionRelativePathElements = versionRelativePathElements
	
	self.shellLanguage = platform.shellScriptExecutor.shellLanguage
	self.objectExtension = platform.objectExtension
end

assert.globalTypeIsFunction('ipairs', 'unpack')
assert.globalTableHasChieldFieldOfTypeFunction('table', 'insert')
function module:baseFilePaths(...)
	local baseFilePaths = {}
	
	for _, stringOrTable in ipairs({...}) do
		local path
		if type.isTable(stringOrTable) then
			path = self:relativeFilePath(unpack(stringOrTable))
		elseif type.isString(stringOrTable) then
			path = self:relativeFilePath(stringOrTable)
		else
			exception.throw('baseFilePaths should only contain strings or tables of string')
		end
		table.insert(baseFilePaths, path)
	end
	return FilePaths:new(baseFilePaths)
end

function module:toObjectsWithoutPaths(baseFilePaths)
	assert.parameterTypeIsInstanceOf('baseFilePaths', baseFilePaths, FilePaths)
	
	return baseFilePaths:toObjectsWithoutPaths(self.objectExtension)
end

function module:relativeFolderPath(...)
	return self.shellLanguage:relativeFolderPath(...)
end

function module:relativeFilePath(...)
	return self.shellLanguage:relativeFilePath(...)
end

function module:_platformPath(pathName)
	assert.parameterTypeIsString('pathName', pathName)
	
	return self.platformPaths[pathName](self.platformPaths, self.versionRelativePathElements)
end

function module:include()
	return self:_platformPath('include')
end

function module:lib()
	return self:_platformPath('lib')
end

function module:locale()
	return self:_platformPath('locale')
end
