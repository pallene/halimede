--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = halimede.exception
local Path = halimede.io.paths.Path
local AlreadyEscapedShellArgument = require.sibling('AlreadyEscapedShellArgument')
local ShellLanguage = require.sibling('ShellLanguage')


moduleclass('ShellPath')

module.static.HALIMEDE_SHELLSCRIPT_ORIGINAL_WORKING_DIRECTORY = function(path)
	return ShellPath:new('HALIMEDE_SHELLSCRIPT_ORIGINAL_WORKING_DIRECTORY', path)
end

module.static.HALIMEDE_SHELLSCRIPT_ABSOLUTE_FOLDER_PATH = function(path)
	return ShellPath:new('HALIMEDE_SHELLSCRIPT_ABSOLUTE_FOLDER_PATH', path)
end

function module:initialize(environmentVariablePrefixOrNil, path)
	assert.parameterTypeIsStringOrNil('environmentVariablePrefixOrNil', environmentVariablePrefixOrNil)
	assert.parameterTypeIsInstanceOf('path', path, Path)
	
	if environmentVariablePrefixOrNil ~= nil then
		path:assertIsRelative('path')
		
		if environmentVariablePrefixOrNil:find('[_A-Z][_A-Z0-9]*') ~= nil then
			exception.throw('environmentVariablePrefixOrNil is restricted (for Windows compatibility) to A-Z, 0-9 and underscore, but 0-9 is not allowed for the first character')
		end
	end
	
	self.environmentVariablePrefixOrNil = environmentVariablePrefixOrNil
	self.path = path
end

function module:quoteArgument(shellLanguage, specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsInstanceOf('shellLanguage', shellLanguage, ShellLanguage)
	assert.parameterTypeIsBoolean('specifyCurrentDirectoryExplicitlyIfAppropriate', specifyCurrentDirectoryExplicitlyIfAppropriate)
	
	local prefix
	if self.environmentVariablePrefixOrNil ~= nil then
		prefix = shellLanguage:quoteEnvironmentVariable(self.environmentVariablePrefixOrNil) .. self.path.pathStyle.folderSeparator
	else
		prefix = ''
	end
	return AlreadyEscapedShellArgument:new(prefix .. shellLanguage:quoteArgument(self.path:toString(specifyCurrentDirectoryExplicitlyIfAppropriate)))
end
