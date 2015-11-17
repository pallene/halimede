--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractPosixShellScriptAction = requireSibling('AbstractPosixShellScriptAction')
moduleclass('MakeSymbolicLinkPosixShellScriptAction', AbstractPosixShellScriptAction)

local assert = require('halimede').assert
local exception = require('halimede.exception')
local Path = require('halimede.io.paths.Path')


function module:initialize(shellScript)
	AbstractPosixShellScriptAction.initialize(self, shellScript)
end

function module:execute(linkContentsPath, linkFilePath)
	assert.parameterTypeIsInstanceOf(linkContentsPath, Path)
	assert.parameterTypeIsInstanceOf(linkFilePath, Path)
	
	if not linkFilePath.isFile then
		exception.throw("linkFilePath '%s' is not a file path", linkFilePath)
	end
	
	self:_appendCommandLineToScript('ln', '-s', linkContentsPath:formatPath(false), linkFilePath:formatPath(false))
end
