--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local ShellPath = halimede.io.shellScript.ShellPath
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction


halimede.moduleclass('MakeDirectoryRecursivelyCmdShellScriptAction', AbstractShellScriptAction)

function module:initialize()
	AbstractShellScriptAction.initialize(self)
end

function module:_execute(shellScript, builder, path, mode)
	assert.parameterTypeIsInstanceOf('path', path, ShellPath)
	assert.parameterTypeIsString('mode', mode)

	-- Problems with Windows mkdir if command extensions are not enabled: https://stackoverflow.com/questions/905226/mkdir-p-linux-windows#905239
	-- We use MD to differentiate from mkdir, which can be present if GNU Utils for Windows are installed
	shellScript:appendCommandLineToScript('MD', path:toQuotedShellArgumentX(true))
end
