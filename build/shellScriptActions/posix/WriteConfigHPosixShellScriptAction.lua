--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractPosixShellScriptAction = requireSibling('AbstractPosixShellScriptAction')
moduleclass('WriteConfigHPosixShellScriptAction', AbstractPosixShellScriptAction)

local assert = require('halimede').assert
local ConfigHDefines = require('halimede.build.defines.ConfigHDefines')
local AbstractPath = require('halimede.io.paths.AbstractPath')


function module:initialize(shellScript)
	AbstractPosixShellScriptAction.initialize(self, shellScript)
end

function module:execute(configHDefines, filePath)
	assert.parameterTypeIsInstanceOf(configHDefines, ConfigHDefines)
	local actualFilePath
	if filePath == nil then
		actualFilePath = 'config.h'
	else
		assert.parameterTypeIsInstanceOf(filePath, AbstractPath)
		actualFilePath = filePath.path
	end
	self:_appendCommandLineToScript('printf', '%s',  configHDefines:toCPreprocessorText(), self:_redirectStandardOutput(actualFilePath))
end
