--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local CompileUnitActions = requireSibling('CompileUnitActions')
local CmdCompileUnitActions = moduleclass('CmdCompileUnitActions', CompileUnitActions)

local halimede = require('halimede')
local assert = halimede.assert
local ShellLanguage = require('halimede.io.shellScript.ShellLanguage')


function CmdCompileUnitActions:initialize(sourcePath, sysrootPath, toolchain)
	AbstractCompileUnitActions.initialise(self, ShellLanguage.Cmd, sourcePath, sysrootPath, toolchain)
end

function CmdCompileUnitActions:_initialBuildScript()
	-- Can't use a multiline string because the new line terminator is then wrong
	self:_appendLinesToScript(
		'@ECHO OFF',
		'SETLOCAL EnableExtensions'
	)
end

function CmdCompileUnitActions:_finalBuildScript()
	self:_appendLinesToScript('ENDLOCAL')
end
