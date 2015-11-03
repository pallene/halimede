--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractPosixShellScriptAction = requireSibling('AbstractPosixShellScriptAction')
moduleclass('SetPathPosixShellScriptAction', AbstractPosixShellScriptAction)

local assert = require('halimede').assert
local Paths = require('halimede.io.paths.Paths')
local UnsetEnvironmentVariablePosixShellScriptAction = requireSibling('UnsetEnvironmentVariablePosixShellScriptAction')
local ExportEnvironmentVariablePosixShellScriptAction = requireSibling('ExportEnvironmentVariablePosixShellScriptAction')


function module:initialize(shellScript, )
	AbstractPosixShellScriptAction.initialize(self, shellScript)
end

function module:execute(paths)
	assert.parameterTypeIsInstanceOf(paths, Paths)
	
	UnsetEnvironmentVariablePosixShellScriptAction.execute(self, 'PATH')
	ExportEnvironmentVariablePosixShellScriptAction.execute(self, 'PATH', paths.paths)
end
