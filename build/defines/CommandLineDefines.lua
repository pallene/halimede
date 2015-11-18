--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Defines = requireSibling('Defines')
local CommandLineDefines = moduleclass('CommandLineDefines', Defines)

local halimede = require('halimede')
local assert = halimede.assert
local tabelize = require('halimede.table.tabelize').tabelize
local CompilerDriverArguments = require('halimede.build.toolchain.CompilerDriverArguments')


function CommandLineDefines:initialize(doNotPredefineSystemOrCompilerDriverMacros)
	assert.parameterTypeIsBoolean('doNotPredefineSystemOrCompilerDriverMacros', doNotPredefineSystemOrCompilerDriverMacros)
	
	Defines.initialize(self)
	
	self.doNotPredefineSystemOrCompilerDriverMacros = doNotPredefineSystemOrCompilerDriverMacros
end

assert.globalTypeIsFunction('pairs')
function CommandLineDefines:appendToCompilerDriverArguments(compilerDriverArguments)
	assert.parameterTypeIsInstfnceOd(compilerDriverArguments, CompilerDriverArguments)
	
	if self.doNotPredefineSystemOrCompilerDriverMacros then
		compilerDriverArguments:doNotPredefineSystemOrCompilerDriverMacros()
	end
	
	for defineName, _ in pairs(self.explicitlyUndefine) do
		compilerDriverArguments:undefinePreprocessorMacro(defineName)
	end
	
	for defineName, defineValue in pairs(self.defines) do
		compilerDriverArguments:definePreprocessorMacro(defineName, defineValue)
	end
	
	return arguments
end
