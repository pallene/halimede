--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local CompilerDriverArguments = moduleclass('CompilerDriverArguments')

local halimede = require('halimede')
local assert = halimede.assert
local type = halimede.type
local CompilerDriver = requireSibling('CompilerDriver')
local Arguments = requireSibling('Arguments')


function CompilerDriverArguments:initialize(compilerDriver, compilerDriverFlags, sysrootPath)
	assert.parameterTypeIsInstanceOf(compilerDriver, CompilerDriver)
	assert.parameterTypeIsTable(compilerDriverFlags)
	assert.parameterTypeIsInstanceOf(sysrootPath, AbsolutePath)
	
	self.arguments = Arguments:new()
	self.arguments:append(self.commandLineName)
	self.arguments:append(self.commandLineFlags)
	self.arguments:append(compilerDriverFlags)
	self.compilerDriver:appendSystemRoot(self.arguments, sysrootPath)
end

function CompilerDriverArguments:append(...)
	self.arguments:append(...)
end

-- Allows to remap standard names for gcc as they change by version, warn about obsolence, etc
function CompilerDriverArguments:addCStandard(cStandard)
	assert.parameterTypeIsInstanceOf(cStandard, CStandard)
	
	self.compilerDriver:addCStandard(self.arguments)
end

function CompilerDriverArguments:doNotPredefineSystemOrCompilerDriverMacros()
	self.compilerDriver:doNotPredefineSystemOrCompilerDriverMacros(self.arguments)
end

function CompilerDriverArguments:undefinePreprocessorMacro(defineName)
	assert.parameterTypeIsString(defineName)
	
	self.compilerDriver:undefinePreprocessorMacro(self.arguments, defineName)
end

function CompilerDriverArguments:definePreprocessorMacro(defineName, defineValue)
	assert.parameterTypeIsString(defineName)
	assert.parameterTypeIsString(defineValue)
	
	self.compilerDriver:definePreprocessorMacro(self.arguments, defineName, defineValue)
end

function CompilerDriverArguments:addSystemIncludePaths(dependenciesSystemIncludePaths, buildVariantSystemIncludePaths)
	assert.parameterTypeIsTable(dependenciesSystemIncludePaths)
	assert.parameterTypeIsTable(buildVariantSystemIncludePaths)
	
	self.compilerDriver:addSystemIncludePaths(self.arguments, dependenciesSystemIncludePaths, buildVariantSystemIncludePaths)
end

function CompilerDriverArguments:addIncludePaths(sources)
	assert.parameterTypeIsTable(sources)
	
	self.compilerDriver:addIncludePaths(self.arguments, sources)
end

function CompilerDriverArguments:addLinkerFlags(dependenciesLinkerFlags, buildVariantLinkerFlags, otherLinkerFlags)
	assert.parameterTypeIsTable(dependenciesLinkerFlags)
	assert.parameterTypeIsTable(buildVariantLinkerFlags)
	assert.parameterTypeIsTable(otherLinkerFlags)
	
	self:compilerDriver:addLinkerFlags(self.arguments, dependenciesLinkerFlags, buildVariantLinkerFlags, otherLinkerFlags)
end

function CompilerDriverArguments:addLinkedLibraries(dependenciesLinkedLibraries, buildVariantLinkedLibraries, otherLinkedLibraries)
	assert.parameterTypeIsTable(dependenciesLinkedLibraries)
	assert.parameterTypeIsTable(buildVariantLinkedLibraries)
	assert.parameterTypeIsTable(otherLinkedLibraries)
	
	self:compilerDriver:addLinkedLibraries(self.arguments, dependenciesLinkedLibraries, buildVariantLinkedLibraries, otherLinkedLibraries)
end

function Arguments:useUnpacked(userFunction)
	assert.parameterTypeIsFunctionOrCall(userFunction)
	
	return self.arguments:useUnpacked(userFunction)
end
