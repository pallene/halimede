--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractExecutableLinkCompilerDriverShellScriptAction = require('halimede.build.shellScriptActions.compilerDriver.AbstractExecutableLinkCompilerDriverShellScriptAction')
moduleclass('ExecutableLinkCompilerDriverPosixShellScriptAction', AbstractExecutableLinkCompilerDriverShellScriptAction)

local UnsetEnvironmentVariablePosixShellScriptAction = require('halimede.build.shellScriptActions.cmd.UnsetEnvironmentVariablePosixShellScriptAction')
local ExportEnvironmentVariablePosixShellScriptAction = require('halimede.build.shellScriptActions.cmd.ExportEnvironmentVariablePosixShellScriptAction')


function module:initialize(shellScript, dependencies, buildVariant)
	AbstractExecutableLinkCompilerDriverShellScriptAction.initialize(self, shellScript, dependencies, buildVariant, UnsetEnvironmentVariablePosixShellScriptAction, ExportEnvironmentVariablePosixShellScriptAction)
end