--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('halimede.middleclass')
local deepCopy = require('halimede.table.deepCopy').deepCopy
local execute = require('halimede.io.execute')
local executeExpectingSuccess = execute.executeExpectingSuccess
local ShellScriptExecutor = requireSibling('ShellScriptExecutor')


local MacOsXHomebrewShellScriptExecutor = class('MacOsXHomebrewShellScriptExecutor', ShellScriptExecutor)

function MacOsXHomebrewShellScriptExecutor:initialize()
	ShellScriptExecutor:initialize(self, 'brew', 'sh')
end

assert.globalTypeIsFunction('unpack')
function ShellScriptExecutor:_executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError, arguments)
	executeExpectingSuccess(scriptFilePath, standardOut, standardError, unpack(arguments))
end


--local commandIsOnPathAndShellIsAvaiableToUseIt = require('halimede.io.commandIsAvailable').commandIsOnPathAndShellIsAvaiableToUseIt

return MacOsXHomebrewShellScriptExecutor:new()
