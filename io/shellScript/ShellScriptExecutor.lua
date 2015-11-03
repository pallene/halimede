--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('halimede.middleclass')
local tabelize = require('halimede.table.tabelize').tabelize
local exception = require('halimede.exception')


local ShellScriptExecutor = class('ShellScriptExecutor')

function ShellScriptExecutor:initialize(...)
	self.shellScriptExecutionCommand = tabelize({...})
end

assert.globalTypeIsFunction('unpack')
function ShellScriptExecutor:executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError)
	assert.parameterTypeIsString(scriptFilePath)
	
	local arguments = deepCopy(self.shellScriptExecutionCommand)
	
	self:_executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError, arguments)
end

function ShellScriptExecutor:_executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError, arguments)
	exception.throw('Abstract Method')
end


return ShellScriptExecutor
