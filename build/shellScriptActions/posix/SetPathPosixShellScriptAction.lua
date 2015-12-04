--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Paths = halimede.io.paths.Paths
local UnsetEnvironmentVariablePosixShellScriptAction = require.sibling('UnsetEnvironmentVariablePosixShellScriptAction')
local ExportEnvironmentVariablePosixShellScriptAction = require.sibling('ExportEnvironmentVariablePosixShellScriptAction')
local AbstractPosixShellScriptAction = require.sibling('AbstractPosixShellScriptAction')


moduleclass('SetPathPosixShellScriptAction', AbstractPosixShellScriptAction)

function module:initialize(shellScript)
	AbstractPosixShellScriptAction.initialize(self, shellScript)
	
	self.unsetEnvironmentVariablePosixShellScriptAction = UnsetEnvironmentVariablePosixShellScriptAction:new(shellScript)
	self.exportEnvironmentVariablePosixShellScriptAction = ExportEnvironmentVariablePosixShellScriptAction:new(shellScript)
end

function module:execute(paths)
	assert.parameterTypeIsInstanceOf('paths', paths, Paths)
	
	self.unsetEnvironmentVariablePosixShellScriptAction:execute('PATH')
	self.exportEnvironmentVariablePosixShellScriptAction:execute('PATH', paths:toStrings(true))
end
