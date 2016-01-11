--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local tabelize = halimede.table.tabelize
local sibling = halimede.build.shellScriptActions
local AbstractShellScriptAction = sibling.AbstractShellScriptAction
local ShellPath = halimede.io.shellScript.ShellPath
local ConfigHDefines = halimede.build.defines.ConfigHDefines
local exception = halimede.exception


halimede.moduleclass('AbstractWriteConfigHShellScriptAction', AbstractShellScriptAction)

function module:initialize(commentShellScriptActionClass)
	assert.parameterTypeIsTable('commentShellScriptActionClass', commentShellScriptActionClass)

	AbstractShellScriptAction.initialize(self)

	self.commentShellScriptAction = commentShellScriptActionClass:new()
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
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'find')
function module:_append(shellScript, quotedStringShellPath, configHDefines)
	local lineSets = configHDefines:toCPreprocessorTextLines()
	
	-- This approach is inefficient, as it involves constantly opening and closing a file handle, but it is simpler to code for and works on Windows (where heredocs and multiline strings are very hard to use)
	local function outputLine(line, redirection)
		if line:find('\0') ~= nil then
			exception.throw("We can not easily support embedded ASCII NUL characters when writing shell scripts")
		end
		
		local arguments = tabelize(self:_line(shellScript, line))
		arguments:insert(redirection)
		shellScript:appendCommandLineToScript(unpack(arguments))
	end
	
	local redirect = shellScript:redirectStandardOutput(quotedStringShellPath)
	local append = shellScript:appendStandardOutput(quotedStringShellPath)
	
	local redirection = redirect
	for _, lineSet in ipairs(lineSets) do
		for _, line in ipairs(lineSet) do
			outputLine(line, redirection)
			redirection = append
		end
		outputLine('', redirection)
	end
end

function module:_line(shellScript, line)
	exception.throw('Abstract method')
end
