--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractShellScriptAction = require.sibling('AbstractShellScriptAction')
local ShellPath = halimede.io.shellScript.ShellPath
local ConfigHDefines = halimede.build.defines.ConfigHDefines
local exception = halimede.exception


moduleclass('AbstractWriteConfigHShellScriptAction', AbstractShellScriptAction)

function module:initialize(commentShellScriptActionClass)
	assert.parameterTypeIsTable('commentShellScriptActionClass', commentShellScriptActionClass)
	
	AbstractShellScriptAction.initialize(self)
	
	self.commentShellScriptAction = commentShellScriptActionClass:new()
end

function module:_execute(shellScript, builder, configHDefines, filePath)
	assert.parameterTypeIsInstanceOf('configHDefines', configHDefines, ConfigHDefines)
	assert.parameterTypeIsInstanceOfOrNil('filePath', filePath, ShellPath)
	
	local actualFilePath
	if filePath == nil then
		actualFilePath = builder.buildFolderShellPath:appendFile('config', 'h')
	else
		filePath:assertIsFilePath('filePath')
		
		actualFilePath = filePath
	end
	
	self.commentShellScriptAction:execute(shellScript, builder, 'Creation of config.h')
	
	local stringFilePath = actualFilePath:toString(true)
	self:_append(shellScript, stringFilePath, configHDefines)
end

function module:_append(shellScript, stringFilePath, configHDefines)
	exception.throw('Abstract method')
end
