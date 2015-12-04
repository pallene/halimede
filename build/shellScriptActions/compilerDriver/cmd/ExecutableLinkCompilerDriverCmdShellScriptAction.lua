--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local UnsetEnvironmentVariableCmdShellScriptAction = halimede.build.shellScriptActions.cmd.UnsetEnvironmentVariableCmdShellScriptAction
local ExportEnvironmentVariableCmdShellScriptAction = halimede.build.shellScriptActions.cmd.ExportEnvironmentVariableCmdShellScriptAction
local AbstractExecutableLinkCompilerDriverShellScriptAction = halimede.build.shellScriptActions.compilerDriver.AbstractExecutableLinkCompilerDriverShellScriptAction


moduleclass('ExecutableLinkCompilerCmdDriverShellScriptAction', AbstractExecutableLinkCompilerDriverShellScriptAction)

function module:initialize(shellScript, dependencies, buildVariant)
	AbstractExecutableLinkCompilerDriverShellScriptAction.initialize(self, shellScript, dependencies, buildVariant, UnsetEnvironmentVariableCmdShellScriptAction, ExportEnvironmentVariableCmdShellScriptAction)
end
