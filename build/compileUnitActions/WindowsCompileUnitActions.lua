--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local CompileUnitActions = requireSibling('CompileUnitActions')
local WindowsCompileUnitActions = moduleclass('WindowsCompileUnitActions', CompileUnitActions)

local halimede = require('halimede')
local assert = halimede.assert
local AbstractPath = require('halimede.io.paths.AbstractPath')
local AbsolutePath = require('halimede.io.paths.AbsolutePath')
local RelativePath = require('halimede.io.paths.RelativePath')
local ShellLanguage = require('halimede.io.shellScript.ShellLanguage')


function WindowsCompileUnitActions:initialize(sourcePath, sysrootPath, toolchain)
	AbstractCompileUnitActions.initialise(self, ShellLanguage.Windows, sourcePath, sysrootPath, toolchain)
end

function WindowsCompileUnitActions:_initialBuildScript()
	
	-- Can't use a multiline string because the new line terminator is then wrong
	self:_appendLinesToBuildScript(
		'@ECHO OFF',
		'SETLOCAL EnableExtensions'
	)
end

assert.globalTypeIsFunction('unpack')
function WindowsCompileUnitActions:_finalBuildScript()
	self:_appendLinesToBuildScript('ENDLOCAL')
end
