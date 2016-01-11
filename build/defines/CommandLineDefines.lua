--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local CompilerDriverArguments = halimede.build.toolchain.CompilerDriverArguments
local sibling = halimede.build.defines
local Defines = sibling.Defines
local ShellLanguage = halimede.io.shellScript.ShellLanguage


halimede.moduleclass('CommandLineDefines', Defines)

function module:initialize(doNotPredefineSystemOrCompilerDriverMacros)
	assert.parameterTypeIsBoolean('doNotPredefineSystemOrCompilerDriverMacros', doNotPredefineSystemOrCompilerDriverMacros)

	Defines.initialize(self)

	self.doNotPredefineSystemOrCompilerDriverMacros = doNotPredefineSystemOrCompilerDriverMacros
end

assert.globalTypeIsFunctionOrCall('pairs')
function module:appendToCompilerDriverArguments(shellLanguage, compilerDriverArguments)
	assert.parameterTypeIsInstanceOf('shellLanguage', shellLanguage, ShellLanguage)
	assert.parameterTypeIsInstanceOf('compilerDriverArguments', compilerDriverArguments, CompilerDriverArguments)

	if self.doNotPredefineSystemOrCompilerDriverMacros then
		compilerDriverArguments:doNotPredefineSystemOrCompilerDriverMacros()
	end
	
	for _, action in ipairs(self.actions) do
		action.appendToCompilerDriverArguments(shellLanguage, compilerDriverArguments)
	end
	return compilerDriverArguments
end
