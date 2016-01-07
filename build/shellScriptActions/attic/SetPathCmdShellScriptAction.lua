--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction
local ShellArgument = halimede.io.shellScript.ShellArgument


halimede.moduleclass('SetPathCmdShellScriptAction', AbstractShellScriptAction)

local escapedArgument_PATH = ShellArgument:new('PATH')
local escapedArgument_Semicolon = ShellArgument:new(';')

function module:initialize()
	AbstractShellScriptAction.initialize(self)
end

function module:_execute(shellScript, builder, paths)
	assert.parameterTypeIsTable('paths', paths)

	-- http://ss64.com/nt/path.html
	shellScript:appendCommandLineToScript(escapedArgument_PATH, escapedArgument_Semicolon)
	if #paths ~= 0 then
		shellScript:appendCommandLineToScript(escapedArgument_PATH, shellScript.shellLanguage:escapeToPathsStringShellArgument(paths, true))
	end
end
