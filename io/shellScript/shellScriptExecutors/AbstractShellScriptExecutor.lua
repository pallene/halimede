--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


moduleclass('AbstractShellScriptExecutor')

local halimede = require('halimede')
local assert = halimede.assert
local class = require('halimede.middleclass')
local tabelize = require('halimede.table.tabelize').tabelize
local exception = require('halimede.exception')
local ShellLanguage = require('halimede.io.shellScript.ShellLanguage')
local BufferedShellScript = require('halimede.io.shellScript.BufferedShellScript')
local AbstractPath = require('halimede.io.paths.AbstractPath')


function module:initialize(shellLanguage, ...)
	assert.parameterTypeIsInstanceOf(shellLanguage, ShellLanguage)
	
	self.shellLanguage = shellLanguage
	self.shellScriptExecutionCommand = tabelize({...})
end

function module:newBufferedShellScript()
	return BufferedShellScript:new(self.shellLanguage)	
end

assert.globalTypeIsFunction('unpack')
function module:executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError)
	assert.parameterTypeIsInstanceOf(scriptFilePath, AbstractPath)
	
	local arguments = deepCopy(self.shellScriptExecutionCommand)
	
	self:_executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError, arguments)
end

function module:_executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError, arguments)
	exception.throw('Abstract Method')
end
