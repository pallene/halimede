--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractShellScriptAction = require.sibling('AbstractShellScriptAction')
local ConfigHDefines = halimede.build.defines.ConfigHDefines
local Path = halimede.io.paths.Path
local exception = halimede.exception


moduleclass('AbstractConfigHShellScriptAction')

function module:initialize(commentShellScriptActionClass)
	assert.parameterTypeIsTable('commentShellScriptActionClass', commentShellScriptActionClass)
	
	AbstractShellScriptAction.initialize(self)
	
	self.commentShellScriptAction = commentShellScriptActionClass:new()
end

function module:execute(shellScript, buildEnvironment, configHDefines, filePath)
	assert.parameterTypeIsInstanceOf('configHDefines', configHDefines, ConfigHDefines)
	assert.parameterTypeIsInstanceOfOrNil('filePath', filePath, Path)
	
	local actualFilePath
	if filePath == nil then
		actualFilePath = buildEnvironment.buildRecipePaths:relativeFilePath('config.h')
	else
		filePath:assertIsFilePath('filePath')
		
		actualFilePath = filePath
	end
	
	self.commentShellScriptAction:execute(shellScript, buildEnvironment, 'Creation of config.h')
	
	local stringFilePath = actualFilePath:toString(true)
	self:_append(shellScript, stringFilePath, configHDefines)
end

function module:_append(shellScript, stringFilePath, configHDefines)
	exception.throw('Abstract method')
end
