--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local ShellPath = halimede.io.shellScript.ShellPath
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction


moduleclass('MakeDirectoryRecursivelyPosixShellScriptAction', AbstractShellScriptAction)

function module:initialize()
	AbstractShellScriptAction.initialize(self)
end

function module:execute(shellScript, builder, path, mode)
	assert.parameterTypeIsInstanceOf('path', path, ShellPath)
	assert.parameterTypeIsString('mode', mode)
	
	shellScript:appendCommandLineToScript('mkdir', '-m', mode, '-p', self:_quoteShellPath(shellScript, path, true))
end
