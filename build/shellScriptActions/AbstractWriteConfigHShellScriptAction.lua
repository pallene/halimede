--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local tabelize = halimede.table.tabelize
local shallowCopy = halimede.table.shallowCopy
local sibling = halimede.build.shellScriptActions
local AbstractShellScriptAction = sibling.AbstractShellScriptAction
local ShellPath = halimede.io.shellScript.ShellPath
local ShellArgument = halimede.io.shellScript.ShellArgument
local ConfigHDefines = halimede.build.defines.ConfigHDefines
local exception = halimede.exception


halimede.moduleclass('AbstractWriteConfigHShellScriptAction', AbstractShellScriptAction)

assert.globalTypeIsFunctionOrCall('ipairs')
function module:initialize(commentShellScriptActionClass, ...)
	assert.parameterTypeIsTable('commentShellScriptActionClass', commentShellScriptActionClass)

	AbstractShellScriptAction.initialize(self)

	self.commentShellScriptAction = commentShellScriptActionClass:new()

	local partialEchoLineShellArguments = tabelize()
	for _, partialEchoLineArgument in ipairs({...}) do
		partialEchoLineShellArguments:insert(ShellArgument:new(partialEchoLineArgument))
	end
	self.partialEchoLineShellArguments = partialEchoLineShellArguments
end

function module:_execute(shellScript, builder, configHDefines, filePath)
	assert.parameterTypeIsInstanceOf('configHDefines', configHDefines, ConfigHDefines)
	assert.parameterTypeIsInstanceOfOrNil('filePath', filePath, ShellPath)

	local actualFilePath
	if filePath == nil then
		actualFilePath = builder.buildFolderShellPath:appendFile('config', 'h')
	else
		filePath:assertIsFilePath('filePath')

		actualFilePath = filePath
	end

	self.commentShellScriptAction:execute(shellScript, builder, 'Creation of config.h')

	local quotedStringShellPath = actualFilePath:escapeToShellArgument(true, shellScript.shellLanguage)
	self:_append(shellScript, quotedStringShellPath, configHDefines)
end

assert.globalTypeIsFunctionOrCall('ipairs', 'unpack')
function module:_append(shellScript, quotedStringShellPath, configHDefines)

	local emptyLine = ShellArgument:new(shellScript:escapeToShellSafeString(''))
	
	-- This approach is inefficient, as it involves constantly opening and closing a file handle, but it is simpler to code for and works on Windows (where heredocs and multiline strings are very hard to use)
	local function outputLine(lineShellArgument, redirection)
		local arguments = shallowCopy(self.partialEchoLineShellArguments)
		arguments:insert(lineShellArgument)
		arguments:insert(redirection)
		shellScript:appendCommandLineToScript(unpack(arguments))
	end

	local lineShellArgumentLists = configHDefines:toCPreprocessorTextLines(shellScript.shellLanguage)
	
	local redirect = shellScript:redirectStandardOutput(quotedStringShellPath)
	local append = shellScript:appendStandardOutput(quotedStringShellPath)
	
	local redirection = redirect
	for _, lineShellArgumentList in ipairs(lineShellArgumentLists) do
		for _, lineShellArgument in ipairs(lineShellArgumentList) do
			outputLine(lineShellArgument, redirection)
			redirection = append
		end
		outputLine(emptyLine, redirection)
	end
end
