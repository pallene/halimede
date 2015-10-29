--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('middleclass')
local AbsolutePath = require('halimede.io.paths.AbsolutePath')


local AbstractCompileUnitActions = class('AbstractCompileUnitActions')

function AbstractCompileUnitActions:initialize(shellLanguage, sourcePath, sysrootPath, compilerDriver)
	assert.parameterTypeIsTable(shellLanguage)
	assert.parameterTypeIsInstanceOf(sourcePath, AbsolutePath)
	assert.parameterTypeIsInstanceOf(sysrootPath, AbsolutePath)
	assert.parameterTypeIsTable(compilerDriver)
	
	self.script = tabelize({})
	self:appendLinesToBuildScript(self._initialBuildScript())
	self.actionChangeDirectory(sourcePath)
end

assert.globalTypeIsFunction('ipairs')
function AbstractCompileUnitActions:appendLinesToBuildScript(...)
	local lines = {...}
	for _, line in ipairs(lines) do
		self.script:insert(line)
		self.script:insert(self.shellLanguage.shellScriptFileExtensionIncludingLeadingPeriod)
	end
end

function AbstractCompileUnitActions:appendCommandLineToBuildScript(...)
	self.script:insert(self.shellLanguage.toShellCommandLine(...))
end

function AbstractCompileUnitActions:completeScript()
	self:appendLinesToBuildScript(self._finishBuildScript())
	return self.script:concat()
end
