--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local tabelize = halimede.table.tabelize
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction
local ShellArgument = halimede.io.shellScript.ShellArgument


halimede.moduleclass('MakeSymbolicLinkWindowsShellScriptAction', AbstractShellScriptAction)

local escapedArgument_MKLINK = ShellArgument:new('MKLINK')
local escapedArgument_SlashD = ShellArgument:new('/D')

function module:initialize()
	AbstractShellScriptAction.initialize(self)
end

-- http://ss64.com/nt/mklink.html (works on Windows Vista and later)
assert.globalTypeIsFunctionOrCall('unpack')
function module:_execute(shellScript, builder, linkContentsPath, linkFilePath)
	assert.parameterTypeIsTable('linkContentsPath', linkContentsPath)
	assert.parameterTypeIsTable('linkFilePath', linkFilePath)

	linkFilePath:assertIsFilePath('linkFilePath')

	local command = tabelize({escapedArgument_MKLINK})

	if linkContentsPath.isDirectory then
		command:insert(escapedArgument_SlashD)
	end

	-- Note that order is reverse of that for POSIX ln -s
	command:insert(linkFilePath:escapeToShellArgument(false, shellScript.shellLanguage))
	command:insert(linkContentsPath:escapeToShellArgument(false, shellScript.shellLanguage))

	shellScript:appendCommandLineToScript(unpack(command))
end
