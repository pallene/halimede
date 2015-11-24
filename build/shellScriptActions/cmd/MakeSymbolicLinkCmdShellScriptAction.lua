--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractCmdShellScriptAction = requireSibling('AbstractCmdShellScriptAction')
moduleclass('MakeSymbolicLinkWindowsShellScriptAction', AbstractCmdShellScriptAction)

local exception = halimede.exception
local tabelize = halimede.table.tabelize
local Path = halimede.io.paths.Path


function module:initialize(shellScript)
	AbstractCmdShellScriptAction.initialize(self, shellScript)
end

-- http://ss64.com/nt/mklink.html (works on Windows Vista and later)
assert.globalTypeIsFunction('unpack')
function module:execute(linkContentsPath, linkFilePath)
	assert.parameterTypeIsInstanceOf('linkContentsPath', linkContentsPath, Path)
	assert.parameterTypeIsInstanceOf('linkFilePath', linkFilePath, Path)
	
	linkFilePath:assertIsFilePath('linkFilePath')
	
	local command = tabelize({'MKLINK'})
	
	if not linkContentsPath.isFile then
		command:insert('/D')
	end
	
	-- Note that order is reverse of that for POSIX ln -s
	command:insert(linkFilePath:toString(false))
	command:insert(linkContentsPath:toString(false))
	
	self:_appendCommandLineToScript(unpack(command))
end
