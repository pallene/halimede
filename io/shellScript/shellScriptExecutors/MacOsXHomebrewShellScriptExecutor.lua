--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractShellScriptExecutor = requireSibling('AbstractShellScriptExecutor')
moduleclass('MacOsXHomebrewShellScriptExecutor', AbstractShellScriptExecutor)

local halimede = require('halimede')
local assert = halimede.assert
local deepCopy = require('halimede.table.deepCopy').deepCopy
local execute = require('halimede.io.execute')
local executeExpectingSuccess = execute.executeExpectingSuccess
local ShellLanguage = require('halimede.io.shellScript.ShellLanguage')


function module:initialize()
	AbstractShellScriptExecutor:initialize(self, ShellLanguage.Posix, 'brew', 'sh')
end

assert.globalTypeIsFunction('unpack')
function module:_executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError, arguments)
	executeExpectingSuccess(self.shellLanguage, scriptFilePath:formatPath(true), standardOut, standardError, unpack(arguments))
end

MacOsXHomebrewShellScriptExecutor.static.MacOsXHomebrewShellScriptExecutor = MacOsXHomebrewShellScriptExecutor:new()
