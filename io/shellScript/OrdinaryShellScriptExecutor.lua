--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local ShellScriptExecutor = requireSibling('ShellScriptExecutor')
local OrdinaryShellScriptExecutor = moduleclass('OrdinaryShellScriptExecutor', ShellScriptExecutor)

local halimede = require('halimede')
local assert = halimede.assert
local class = require('halimede.middleclass')
local deepCopy = require('halimede.table.deepCopy').deepCopy
local execute = require('halimede.io.execute')
local executeExpectingSuccess = execute.executeExpectingSuccess
local noRedirection = execute.noRedirection

function OrdinaryShellScriptExecutor:initialize(...)
	ShellScriptExecutor:initialize(self, ...)
end

assert.globalTypeIsFunction('unpack')
function ShellScriptExecutor:_executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError, arguments)
	arguments:insert(scriptFilePath)
	executeExpectingSuccess(noRedirection, standardOut, standardError, unpack(arguments))
end

OrdinaryShellScriptExecutor.static.Posix = OrdinaryShellScriptExecutor:new('sh')
OrdinaryShellScriptExecutor.static.Cmd = OrdinaryShellScriptExecutor:new('cmd', '/c', '/e:on', '/u')
