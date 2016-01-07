--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction
local ShellArgument = halimede.io.shellScript.ShellArgument


halimede.moduleclass('PopdPosixShellScriptAction', AbstractShellScriptAction)

local escapedArgument_popd = ShellArgument:new('popd')

function module:initialize()
	AbstractShellScriptAction.initialize(self)
end

function module:_execute(shellScript, builder)
	-- Relies on compatibility functions in StartPosixShellScriptAction
	shellScript:appendCommandLineToScript(escapedArgument_popd)
end
