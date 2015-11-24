--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractShellScriptExecutor = requireSibling('AbstractShellScriptExecutor')
local OrdinaryShellScriptExecutor = moduleclass('OrdinaryShellScriptExecutor', AbstractShellScriptExecutor)

local halimede = require('halimede')
local deepCopy = halimede.table.deepCopy
local ShellLanguage = halimede.io.shellScript.ShellLanguage
local noRedirection = ShellLanguage.noRedirection


function module:initialize(shellLanguage, ...)
	AbstractShellScriptExecutor.initialize(self, shellLanguage, shellLanguage.commandInterpreterName, ...)
	
	OrdinaryShellScriptExecutor.static[shellLanguage.titleCasedName] = self
end

assert.globalTypeIsFunction('unpack')
function module:_executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError, arguments)
	arguments:insert(scriptFilePath:toString(true))
	self.shellLanguage:executeExpectingSuccess(noRedirection, standardOut, standardError, unpack(arguments))
end

OrdinaryShellScriptExecutor:new(ShellLanguage.Posix)
OrdinaryShellScriptExecutor:new(ShellLanguage.Cmd, '/c', '/e:on', '/u')
