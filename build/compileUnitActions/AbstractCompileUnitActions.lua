--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractCompileUnitActions = moduleclass('AbstractCompileUnitActions')

local halimede = require('halimede')
local assert = halimede.assert
local basename = halimede.basename
local class = require('halimede.middleclass')
local AbsolutePath = require('halimede.io.paths.AbsolutePath')
local writeToFileAllContentsInTextMode = require('halimede.io.write').writeToFileAllContentsInTextMode
local execute = require('halimede.io.execute')
local noRedirection = execute.noRedirection
local CStandard = require('halimede.build.toolchain.CStandard')
local LegacyCandCPlusPlusStringLiteralEncoding = require('halimede.build.toolchain.LegacyCandCPlusPlusStringLiteralEncoding')
local BufferedShellScript = require('halimede.io.shellScript.BufferedShellScript')
local CommandLineDefines = require('halimede.build.defines.CommandLineDefines')
local Arguments = require('halimede.build.toolchain.Arguments')
local Toolchain = require('halimede.build.toolchain.Toolchain')


function AbstractCompileUnitActions:initialize(buildToolchain, crossToolchain, dependencies, buildVariant, sourcePath)
	assert.parameterTypeIsInstanceOf(buildToolchain, Toolchain)
	assert.parameterTypeIsInstanceOf(crossToolchain, Toolchain)
	assert.parameterTypeIsTable(dependencies)
	assert.parameterTypeIsTable(buildVariant)
	assert.parameterTypeIsInstanceOf(sourcePath, AbsolutePath)
	
	self.dependencies = dependencies
	self.buildVariant = buildVariant
	self.sourcePath = sourcePath
	
	self.shellLanguage = ??? -- of the build platform
	self.shellScriptExecutor = ???  -- of the build platform
	
	self.shellScript = BufferedShellScript:new(shellLanguage)
	self._initialBuildScript()
	self.actionChangeDirectory(sourcePath)
end




function AbstractCompileUnitActions:executeScriptExpectingSuccess()
	self._finishBuildScript()
	self.shellScript:executeScriptExpectingSuccess(shellScriptExecutor, noRedirection, noRedirection)
end
