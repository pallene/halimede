--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = halimede.exception
local tabelize = halimede.table.tabelize
local ShellPath = halimede.io.shellScript.ShellPath
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction


moduleclass('MakeSymbolicLinkWindowsShellScriptAction', AbstractShellScriptAction)

function module:initialize()
	AbstractShellScriptAction.initialize(self)
end

-- http://ss64.com/nt/mklink.html (works on Windows Vista and later)
assert.globalTypeIsFunctionOrCall('unpack')
function module:_execute(shellScript, builder, linkContentsPath, linkFilePath)
	assert.parameterTypeIsInstanceOf('linkContentsPath', linkContentsPath, ShellPath)
	assert.parameterTypeIsInstanceOf('linkFilePath', linkFilePath, ShellPath)
	
	linkFilePath:assertIsFilePath('linkFilePath')
	
	local command = tabelize({'MKLINK'})
	
	if linkContentsPath.isDirectory then
		command:insert('/D')
	end
	
	-- Note that order is reverse of that for POSIX ln -s
	command:insert(linkFilePath:quoteArgumentX(false))
	command:insert(linkContentsPath:quoteArgumentX(false))
	
	shellScript:appendCommandLineToScript(unpack(command))
end
