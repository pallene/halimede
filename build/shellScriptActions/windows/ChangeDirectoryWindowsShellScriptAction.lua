--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractPosixShellScriptAction = requireSibling('AbstractPosixShellScriptAction')
moduleclass('ChangeDirectoryPosixShellScriptAction', AbstractPosixShellScriptAction)

local assert = require('halimede').assert
local AbstractPath = require('halimede.io.paths.AbstractPath')
local class = require('halimede.middleclass')
local Object = class.Object


function module:initialize(shellScript)
	AbstractPosixShellScriptAction.initialize(self, shellScript)
end

function module:execute(abstractPath)
	assert.parameterTypeIsInstanceOf(abstractPath, AbstractPath)

	if Object.isInstanceOf(abstractPath, AbsolutePath) then
		self:_appendCommandLineToBuildScript('CD', '/D', abstractPath.path)
	else
		self:_appendCommandLineToBuildScript('CD', abstractPath.path)
	end
end
