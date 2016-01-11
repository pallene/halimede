--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractWriteConfigHShellScriptAction = halimede.build.shellScriptActions.AbstractWriteConfigHShellScriptAction
local CommentPosixShellScriptAction = halimede.build.shellScriptActions.CommentPosixShellScriptAction
local ShellArgument = halimede.io.shellScript.ShellArgument


halimede.moduleclass('WriteConfigHPosixShellScriptAction', AbstractWriteConfigHShellScriptAction)

local escapedArgument_printf = ShellArgument:new('printf')
local escapedArgument_printfTemplate = ShellArgument:new("'%s\\n'")

function module:initialize()
	AbstractWriteConfigHShellScriptAction.initialize(self, CommentPosixShellScriptAction)
end

function module:_line(shellScript, line)
	-- We use 'print' over 'echo' because the latter escapes certain argument sequences
	return {escapedArgument_printf, escapedArgument_printfTemplate, ShellArgument:new(shellScript:escapeToShellSafeString(line))}
end
