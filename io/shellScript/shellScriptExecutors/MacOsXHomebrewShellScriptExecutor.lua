--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local deepCopy = halimede.table.deepCopy
local ShellLanguage = halimede.io.shellScript.ShellLanguage
local AbstractShellScriptExecutor = require.sibling('AbstractShellScriptExecutor')


local MacOsXHomebrewShellScriptExecutor = moduleclass('MacOsXHomebrewShellScriptExecutor', AbstractShellScriptExecutor)

function module:initialize()
	AbstractShellScriptExecutor.initialize(self, ShellLanguage.Posix, 'brew', 'sh')
end

assert.globalTypeIsFunctionOrCall('unpack')
function module:_executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError, arguments)
	self.shellLanguage:executeExpectingSuccess(scriptFilePath:toString(true), standardOut, standardError, unpack(arguments))
end

module.static.MacOsXHomebrewShellScriptExecutor = MacOsXHomebrewShellScriptExecutor:new()
