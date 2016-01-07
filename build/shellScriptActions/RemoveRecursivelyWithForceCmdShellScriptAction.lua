--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local ShellPath = halimede.io.shellScript.ShellPath
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction
local ShellArgument = halimede.io.shellScript.ShellArgument


halimede.moduleclass('RemoveRecursivelyWithForceCmdShellScriptAction', AbstractShellScriptAction)

local escapedArgument_RD = ShellArgument:new('RD')
local escapedArgument_SlashS = ShellArgument:new('/S')
local escapedArgument_SlashQ = ShellArgument:new('/Q')

function module:initialize()
	AbstractShellScriptAction.initialize(self)
end

function module:_execute(shellScript, builder, path)
	assert.parameterTypeIsInstanceOf('path', path, ShellPath)

	-- Not really equivalent to rm -rf; doesn't delete files. See https://stackoverflow.com/questions/97875/rm-rf-equivalent-for-windows
	shellScript:appendCommandLineToScript(escapedArgument_RD, escapedArgument_SlashS, escapedArgument_SlashQ, path:escapeToShellArgument(true, shellScript.shellLanguage))
end
