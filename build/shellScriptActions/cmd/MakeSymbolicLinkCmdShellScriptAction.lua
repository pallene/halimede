--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractCmdShellScriptAction = requireSibling('AbstractCmdShellScriptAction')
moduleclass('MakeSymbolicLinkWindowsShellScriptAction', AbstractCmdShellScriptAction)

local assert = require('halimede').assert
local exception = require('halimede.exception')
local tabelize = require('halimede.table.tabelize').tabelize
local Path = require('halimede.io.paths.Path')


function module:initialize(shellScript)
	AbstractCmdShellScriptAction.initialize(self, shellScript)
end

-- http://ss64.com/nt/mklink.html (works on Windows Vista and later)
assert.globalTypeIsFunction('unpack')
function module:execute(linkContentsPath, linkFilePath)
	assert.parameterTypeIsInstanceOf(linkContentsPath, Path)
	assert.parameterTypeIsInstanceOf(linkFilePath, Path)
	
	linkFilePath:assertIsFilePath('linkFilePath')
	
	local command = tabelize({'MKLINK'})
	
	if not linkContentsPath.isFile then
		command:insert('/D')
	end
	
	-- Note that order is reverse of that for POSIX ln -s
	command:insert(linkFilePath:formatPath(false))
	command:insert(linkContentsPath:formatPath(false))
	
	self:_appendCommandLineToScript(unpack(command))
end
