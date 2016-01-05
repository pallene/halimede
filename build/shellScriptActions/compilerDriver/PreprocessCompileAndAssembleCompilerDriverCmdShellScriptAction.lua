--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local UnsetEnvironmentVariableCmdShellScriptAction = halimede.build.shellScriptActions.UnsetEnvironmentVariableCmdShellScriptAction
local ExportEnvironmentVariableCmdShellScriptAction = halimede.build.shellScriptActions.ExportEnvironmentVariableCmdShellScriptAction
local AbstractPreprocessCompileAndAssembleCompilerDriverShellScriptAction = halimede.build.shellScriptActions.compilerDriver.AbstractPreprocessCompileAndAssembleCompilerDriverShellScriptAction


halimede.moduleclass('PreprocessCompileAndAssembleCompilerDriverCmdShellScriptAction', AbstractPreprocessCompileAndAssembleCompilerDriverShellScriptAction)

function module:initialize(dependencies, buildVariant)
	AbstractPreprocessCompileAndAssembleCompilerDriverShellScriptAction.initialize(self, dependencies, buildVariant, UnsetEnvironmentVariableCmdShellScriptAction, ExportEnvironmentVariableCmdShellScriptAction)
end
