--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractPosixShellScriptAction = requireSibling('AbstractPosixShellScriptAction')
moduleclass('MakeDirectoryRecursivelyPosixShellScriptAction', AbstractPosixShellScriptAction)

local assert = require('halimede').assert
local AbstractPath = require('halimede.io.paths.AbstractPath')
local class = require('halimede.middleclass')
local Object = class.Object


function module:initialize(shellScript)
	AbstractPosixShellScriptAction.initialize(self, shellScript)
end

function module:execute(abstractPath, mode)
	assert.parameterTypeIsInstanceOf(abstractPath, AbstractPath)
	assert.parameterTypeIsString(mode)

	local path
	if Object.isInstanceOf(abstractPath, AbsolutePath) then
		path = abstractPath.path
	else
		path = '\\' .. abstractPath.path
	end
	
	-- Problems with Windows mkdir if command extensions are not enabled: https://stackoverflow.com/questions/905226/mkdir-p-linux-windows#905239
	-- We use MD to differentiate from mkdir, which can be present if GNU Utils for Windows are installed
	self:_appendCommandLineToBuildScript('MD', path)
end
