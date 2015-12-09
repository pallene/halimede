--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Paths = halimede.io.paths.Paths
local UnsetEnvironmentVariablePosixShellScriptAction = require.sibling('UnsetEnvironmentVariablePosixShellScriptAction')
local ExportEnvironmentVariablePosixShellScriptAction = require.sibling('ExportEnvironmentVariablePosixShellScriptAction')
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction


moduleclass('SetPathPosixShellScriptAction', AbstractShellScriptAction)

function module:initialize()
	AbstractShellScriptAction.initialize(self)
	
	self.unsetEnvironmentVariablePosixShellScriptAction = UnsetEnvironmentVariablePosixShellScriptAction:new(shellScript)
	self.exportEnvironmentVariablePosixShellScriptAction = ExportEnvironmentVariablePosixShellScriptAction:new(shellScript)
end

function module:execute(shellScript, paths)
	assert.parameterTypeIsInstanceOf('paths', paths, Paths)
	
	self.unsetEnvironmentVariablePosixShellScriptAction:execute(shellScript, 'PATH')
	self.exportEnvironmentVariablePosixShellScriptAction:execute(shellScript, 'PATH', paths:toStrings(true))
end
