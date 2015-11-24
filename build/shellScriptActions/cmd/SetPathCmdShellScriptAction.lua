--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractCmdShellScriptAction = requireSibling('AbstractCmdShellScriptAction')
moduleclass('SetPathCmdShellScriptAction', AbstractCmdShellScriptAction)

local Paths = halimede.io.paths.Paths


function module:initialize(shellScript)
	AbstractCmdShellScriptAction.initialize(self, shellScript)
end

function module:execute(paths)
	assert.parameterTypeIsInstanceOf('paths', paths, Paths)

	-- http://ss64.com/nt/path.html
	self:_appendCommandLineToScript('PATH', ';')
	self:_appendCommandLineToScript('PATH', paths:toStrings(true))
end
