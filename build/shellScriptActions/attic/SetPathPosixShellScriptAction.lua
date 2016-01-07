--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local UnsetEnvironmentVariablePosixShellScriptAction = halimede.build.shellScriptActions.UnsetEnvironmentVariablePosixShellScriptAction
local ExportEnvironmentVariablePosixShellScriptAction = halimede.build.shellScriptActions.ExportEnvironmentVariablePosixShellScriptAction
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction


halimede.moduleclass('SetPathPosixShellScriptAction', AbstractShellScriptAction)

function module:initialize()
	AbstractShellScriptAction.initialize(self)

	self.unsetEnvironmentVariablePosixShellScriptAction = UnsetEnvironmentVariablePosixShellScriptAction:new(shellScript)
	self.exportEnvironmentVariablePosixShellScriptAction = ExportEnvironmentVariablePosixShellScriptAction:new(shellScript)
end

function module:_execute(shellScript, builder, paths)
	assert.parameterTypeIsTable('paths', paths)

	-- Sadly, on Windows, the current folder is by default part of the path
	self.unsetEnvironmentVariablePosixShellScriptAction:execute(shellScript, builder, 'PATH')
	self.exportEnvironmentVariablePosixShellScriptAction:execute(shellScript, builder, 'PATH', shellScript.shellLanguage:escapeToPathsStringShellArgument(paths, true))
end
