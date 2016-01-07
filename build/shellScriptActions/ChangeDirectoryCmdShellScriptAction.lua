--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local tabelize = halimede.table.tabelize
local ShellPath = halimede.io.shellScript.ShellPath
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction
local ShellArgument = halimede.io.shellScript.ShellArgument


halimede.moduleclass('ChangeDirectoryCmdShellScriptAction', AbstractShellScriptAction)

local escapedArgument_CD = ShellArgument:new('CD')
local escapedArgument_SlashD = ShellArgument:new('/D')

function module:initialize()
	AbstractShellScriptAction.initialize(self)
end

assert.globalTypeIsFunctionOrCall('unpack')
function module:_execute(shellScript, builder, path)
	assert.parameterTypeIsTable('path', path)

	local command = tabelize({escapedArgument_CD})

	if path:hasNonEmptyDevice() then
		command:insert(escapedArgument_SlashD)
	end

	command:insert(path:escapeToShellArgument(true, shellScript.shellLanguage))

	shellScript:appendCommandLineToScript(unpack(command))
end
