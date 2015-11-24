--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


moduleclass('Toolchain')

local halimede = require('halimede')
local tabelize = halimede.table.tabelize
local exception = halimede.exception
local Platform = requireSibling('Platform')
local ToolchainPaths = requireSibling('ToolchainPaths')
local FilePaths = requireSibling('FilePaths')


function module:initialize(platform, toolchainPaths)
	assert.parameterTypeIsInstanceOf('platform', platform, Platform)
	assert.parameterTypeIsInstanceOf('toolchainPaths', toolchainPaths, ToolchainPaths)
	
	self.platform = platform
	self.toolchainPaths = toolchainPaths
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
	
	return baseFilePaths:toObjectsWithoutPaths(self.platform.objectExtension)
end

function module:relativeFolderPath(...)
	return self.platform.shellScriptExecutor.shellLanguage:relativeFolderPath(...)
end

function module:relativeFilePath(...)
	return self.platform.shellScriptExecutor.shellLanguage:relativeFilePath(...)
end

function module:toolchainPath(pathName)
	return self.platform:toolchainPath(self.toolchainPaths, pathName)
end

function module:include()
	return self:toolchainPath('include')
end

function module:lib()
	return self:toolchainPath('lib')
end

function module:locale()
	return self:toolchainPath('locale')
end
