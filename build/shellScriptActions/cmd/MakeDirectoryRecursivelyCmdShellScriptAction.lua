--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractCmdShellScriptAction = requireSibling('AbstractCmdShellScriptAction')
moduleclass('MakeDirectoryRecursivelyCmdShellScriptAction', AbstractCmdShellScriptAction)

local assert = require('halimede').assert
local Path = require('halimede.io.paths.Path')


function module:initialize(shellScript)
	AbstractCmdShellScriptAction.initialize(self, shellScript)
end

function module:execute(path, mode)
	assert.parameterTypeIsInstanceOf(path, Path)
	assert.parameterTypeIsString(mode)
	
	-- Problems with Windows mkdir if command extensions are not enabled: https://stackoverflow.com/questions/905226/mkdir-p-linux-windows#905239
	-- We use MD to differentiate from mkdir, which can be present if GNU Utils for Windows are installed
	self:_appendCommandLineToScript('MD', path.formatPath(true))
end
