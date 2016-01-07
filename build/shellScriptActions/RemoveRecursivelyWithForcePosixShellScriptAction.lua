--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local ShellPath = halimede.io.shellScript.ShellPath
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction
local ShellArgument = halimede.io.shellScript.ShellArgument


halimede.moduleclass('RemoveRecursivelyWithForcePosixShellScriptAction', AbstractShellScriptAction)

local escapedArgument_rm = ShellArgument:new('rm')
local escapedArgument_rf = ShellArgument:new('-rf')


function module:initialize()
	AbstractShellScriptAction.initialize(self)
end

function module:_execute(shellScript, builder, path)
	assert.parameterTypeIsInstanceOf('path', path, ShellPath)

	shellScript:appendCommandLineToScript(escapedArgument_rm, escapedArgument_rf, path:escapeToShellArgument(true, shellScript.shellLanguage))
end
