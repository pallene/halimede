--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = halimede.exception
local Path = halimede.io.paths.Path
local AlreadyEscapedShellArgument = require.sibling('AlreadyEscapedShellArgument')
local ShellLanguage = require.sibling('ShellLanguage')
local isInstanceOf = halimede.class.Object.isInstanceOf
local tabelize = halimede.table.tabelize


local ShellPath = moduleclass('ShellPath')

module.setInstanceMissingIndex(function(instance, key)

	local delegatedInstance = instance.path
	
	local underlyingMethodOrField = delegatedInstance[key]
	
	if type.isFunctionOrCall(underlyingMethodOrField) then
		return function(self, ...)
			-- Were we called MyInstance:MissingInstanceMethod() (if) or MyInstance.MissingInstanceMethod() (else)?
			-- Not perfect; fails if any method takes itself as a second argument (eg a comparison function)
			local underlyingResult
			if self == instance then
				underlyingResult = underlyingMethodOrField(delegatedInstance, ...)
			else
				underlyingResult = underlyingMethodOrField(delegatedInstance, self, ...)
			end
			
			if isInstanceOf(underlyingResult, Path) then
				return ShellPath:new(instance.shellLanguage, instance.environmentVariablePrefixOrNil, underlyingResult)
			else
				return underlyingResult
			end
		end
	else
		return underlyingMethodOrField
	end
end)

module.static.HALIMEDE_SHELLSCRIPT_ORIGINAL_WORKING_DIRECTORY = function(shellLanguage, path)
	return ShellPath:new(shellLanguage, 'HALIMEDE_SHELLSCRIPT_ORIGINAL_WORKING_DIRECTORY', path)
end

module.static.HALIMEDE_SHELLSCRIPT_ABSOLUTE_FOLDER_PATH = function(shellLanguage, path)
	return ShellPath:new(shellLanguage, 'HALIMEDE_SHELLSCRIPT_ABSOLUTE_FOLDER_PATH', path)
end

assert.globalTypeIsFunctionOrCall('ipairs', 'error', 'setmetatable')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'match')
function module:initialize(shellLanguage, environmentVariablePrefixOrNil, path)
	assert.parameterTypeIsInstanceOf('shellLanguage', shellLanguage, ShellLanguage)
	assert.parameterTypeIsStringOrNil('environmentVariablePrefixOrNil', environmentVariablePrefixOrNil)
	assert.parameterTypeIsInstanceOf('path', path, Path)
	
	if environmentVariablePrefixOrNil ~= nil then
		path:assertIsRelative('path')
		
		if environmentVariablePrefixOrNil:match('[_A-Z][_A-Z0-9]*') ~= environmentVariablePrefixOrNil then
			exception.throw("environmentVariablePrefixOrNil '%s' is restricted (for Windows compatibility) to A-Z, 0-9 and underscore, but 0-9 is not allowed for the first character", environmentVariablePrefixOrNil)
		end
	end
	
	self.shellLanguage = shellLanguage
	self.environmentVariablePrefixOrNil = environmentVariablePrefixOrNil
	self.path = path
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:filePaths(fileExtension, baseFilePaths)
	-- No type checks
	
	local paths = self.path:filePaths(fileExtension, baseFilePaths)
	local result = tabelize()
	for _, path in ipairs(paths) do
		result:insert(ShellPath:new(self.shellLanguage, self.environmentVariablePrefixOrNil, path))
	end
	return result
end

assert.globalTypeIsFunctionOrCall('tostring')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'format')
function module:__tostring()
	return ('%s(%s, %s)'):format(self.class.name, self.environmentVariablePrefixOrNil, self.path)
end

function module:toString(specifyCurrentDirectoryExplicitlyIfAppropriate)
	exception.throw('Do not use this method willy-nilly; there are argument impacts')
end

function module:_toString(specifyCurrentDirectoryExplicitlyIfAppropriate)
	local prefix
	if self.environmentVariablePrefixOrNil ~= nil then
		prefix = self.shellLanguage:quoteEnvironmentVariable(self.environmentVariablePrefixOrNil) .. self.path.pathStyle.folderSeparator
	else
		prefix = ''
	end
	
	return prefix .. self.shellLanguage:quoteArgument(self.path:toString(specifyCurrentDirectoryExplicitlyIfAppropriate))
end

function module:quoteArgumentX(specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsBoolean('specifyCurrentDirectoryExplicitlyIfAppropriate', specifyCurrentDirectoryExplicitlyIfAppropriate)
	
	return AlreadyEscapedShellArgument:new(self:_toString(specifyCurrentDirectoryExplicitlyIfAppropriate))
end
