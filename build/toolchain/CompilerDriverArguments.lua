--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


moduleclass('CompilerDriverArguments')

local halimede = require('halimede')
local CompilerDriver = requireSibling('CompilerDriver')
local Arguments = requireSibling('Arguments')
local FilePaths = requireSibling('FilePaths')
local Path = require('halimede.io.paths.Path')


function module:initialize(compilerDriver, compilerDriverFlags, sysrootPath)
	assert.parameterTypeIsInstanceOf('compilerDriver', compilerDriver, CompilerDriver)
	assert.parameterTypeIsTable('compilerDriverFlags', compilerDriverFlags)
	assert.parameterTypeIsInstanceOf('sysrootPath', sysrootPath, Path)
	
	self.arguments = Arguments:new()
	self.arguments:append(self.commandLineName)
	self.arguments:append(self.commandLineFlags)
	self.arguments:append(compilerDriverFlags)
	self.compilerDriver:appendSystemRoot(self.arguments, sysrootPath)
end

function module:append(...)
	self.arguments:append(...)
end

function module:appendFilePaths(filePaths)
	assert.parameterTypeIsInstanceOf('filePaths', filePaths, FilePaths)
	
	for path in filePaths:iterate() do
		self.arguments:append(path:toString(true))
	end
end

-- Allows to remap standard names for gcc as they change by version, warn about obsolence, etc
function module:addCStandard(cStandard)
	assert.parameterTypeIsInstanceOf('cStandard', cStandard, CStandard)
	
	self.compilerDriver:addCStandard(self.arguments)
end

function module:doNotPredefineSystemOrCompilerDriverMacros()
	self.compilerDriver:doNotPredefineSystemOrCompilerDriverMacros(self.arguments)
end

function module:undefinePreprocessorMacro(defineName)
	assert.parameterTypeIsString('defineName', defineName)
	
	self.compilerDriver:undefinePreprocessorMacro(self.arguments, defineName)
end

function module:definePreprocessorMacro(defineName, defineValue)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsString('defineValue', defineValue)
	
	self.compilerDriver:definePreprocessorMacro(self.arguments, defineName, defineValue)
end

function module:addSystemIncludePaths(dependenciesSystemIncludePaths, buildVariantSystemIncludePaths)
	assert.parameterTypeIsTable('dependenciesSystemIncludePaths', dependenciesSystemIncludePaths)
	assert.parameterTypeIsTable('buildVariantSystemIncludePaths', buildVariantSystemIncludePaths)
	
	self.compilerDriver:addSystemIncludePaths(self.arguments, dependenciesSystemIncludePaths, buildVariantSystemIncludePaths)
end

function module:addIncludePaths(sourceFilePaths)
	assert.parameterTypeIsInstanceOf('sourceFilePaths', sourceFilePaths, FilePaths)
	
	self.compilerDriver:addIncludePaths(self.arguments, sourceFilePaths)
end

function module:addLinkerFlags(dependenciesLinkerFlags, buildVariantLinkerFlags, otherLinkerFlags)
	assert.parameterTypeIsTable('dependenciesLinkerFlags', dependenciesLinkerFlags)
	assert.parameterTypeIsTable('buildVariantLinkerFlags', buildVariantLinkerFlags)
	assert.parameterTypeIsTable('otherLinkerFlags', otherLinkerFlags)
	
	self.compilerDriver:addLinkerFlags(self.arguments, dependenciesLinkerFlags, buildVariantLinkerFlags, otherLinkerFlags)
end

function module:addLinkedLibraries(dependenciesLinkedLibraries, buildVariantLinkedLibraries, otherLinkedLibraries)
	assert.parameterTypeIsTable('dependenciesLinkedLibraries', dependenciesLinkedLibraries)
	assert.parameterTypeIsTable('buildVariantLinkedLibraries', buildVariantLinkedLibraries)
	assert.parameterTypeIsTable('otherLinkedLibraries', otherLinkedLibraries)
	
	self.compilerDriver:addLinkedLibraries(self.arguments, dependenciesLinkedLibraries, buildVariantLinkedLibraries, otherLinkedLibraries)
end

function Arguments:useUnpacked(userFunction)
	assert.parameterTypeIsFunctionOrCall('userFunction', userFunction)
	
	return self.arguments:useUnpacked(userFunction)
end
