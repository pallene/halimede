--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractCmdShellScriptAction = requireSibling('AbstractCmdShellScriptAction')
moduleclass('MakeSymbolicLinkWindowsShellScriptAction', AbstractCmdShellScriptAction)

local assert = require('halimede').assert
local AbstractPath = require('halimede.io.paths.AbstractPath')


function module:initialize(shellScript)
	AbstractCmdShellScriptAction.initialize(self, shellScript)
end

-- http://ss64.com/nt/mklink.html (works on Windows Vista and later)
function module:execute(abstractLinkContentsFilePath, abstractLinkFilePath, isDirectory)
	assert.parameterTypeIsInstanceOf(abstractLinkContentsFilePath, AbstractPath)
	assert.parameterTypeIsInstanceOf(abstractLinkFilePath, AbstractPath)
	
	if isDirectory then
		self:_appendCommandLineToScript('MKLINK', '/D', abstractLinkFilePath.path, abstractLinkContentsFilePath.path)
	else
		self:_appendCommandLineToScript('MKLINK', abstractLinkFilePath.path, abstractLinkContentsFilePath.path)
	end
end
