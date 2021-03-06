--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local tabelize = halimede.table.tabelize
local deepCopy = halimede.table.deepCopy
local exception = halimede.exception
local ShellLanguage = halimede.io.shellScript.ShellLanguage
local Path = halimede.io.paths.Path


halimede.moduleclass('AbstractShellScriptExecutor')

function module:initialize(shellLanguage, ...)
	assert.parameterTypeIsInstanceOf('shellLanguage', shellLanguage, ShellLanguage)

	self.shellLanguage = shellLanguage
	self.shellScriptExecutionCommand = tabelize({...})
end

function module:newShellScript(shellScriptClass, ...)
	assert.parameterTypeIsTable('shellScriptClass', shellScriptClass)

	return shellScriptClass:new(self, ...)
end

assert.globalTypeIsFunctionOrCall('unpack')
function module:executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError)
	assert.parameterTypeIsInstanceOf('scriptFilePath', scriptFilePath, Path)

	scriptFilePath:assertIsFilePath('scriptFilePath')

	local arguments = deepCopy(self.shellScriptExecutionCommand)

	self:_executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError, arguments)
end

--noinspection UnusedDef
function module:_executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError, arguments)
	exception.throw('Abstract Method')
end
