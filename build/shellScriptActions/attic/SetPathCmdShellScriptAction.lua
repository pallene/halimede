--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Paths = halimede.io.paths.Paths
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction


moduleclass('SetPathCmdShellScriptAction', AbstractShellScriptAction)

function module:initialize()
	AbstractShellScriptAction.initialize(self)
end

function module:_execute(shellScript, buildEnvironment, paths)
	assert.parameterTypeIsInstanceOf('paths', paths, Paths)

	-- http://ss64.com/nt/path.html
	shellScript:appendCommandLineToScript('PATH', ';')
	shellScript:appendCommandLineToScript('PATH', paths:toStrings(true))
end
