--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local tabelize = halimede.table.tabelize
local AbstractShellScriptExecutor = halimede.io.shellScript.shellScriptExecutors.AbstractShellScriptExecutor
local Path = halimede.io.paths.Path
local openBinaryFileForWriting = halimede.io.FileHandleStream.openBinaryFileForWriting


halimede.moduleclass('ShellScript')

function module:initialize(shellScriptExecutor)
	assert.parameterTypeIsInstanceOf('shellScriptExecutor', shellScriptExecutor, AbstractShellScriptExecutor)

	self.shellScriptExecutor = shellScriptExecutor

	local shellLanguage = shellScriptExecutor.shellLanguage
	self.shellLanguage = shellLanguage
	self.tabelizedScriptBuffer = tabelize()
end

function module:finish()
	local script = self.tabelizedScriptBuffer:concat()
	self.tabelizedScriptBuffer = tabelize()
	return script
end

-- take another look at 'brew sh': it's really part of how we execute [indeed, we should probably look at that in more depth, with perhaps a wrapper script]
function module:writeToFileAndExecute(scriptFilePath, standardOut, standardError)
	assert.parameterTypeIsInstanceOf('scriptFilePath', scriptFilePath, Path)

	scriptFilePath:assertIsFilePath('scriptFilePath')

	local fileHandleStream = scriptFilePath:openFile(openBinaryFileForWriting, 'build script')
	fileHandleStream:writeAllContentsAndClose(self:finish())

	self.shellScriptExecutor:executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError)
end

function module:escapeToShellSafeString(argument)
	return self.shellLanguage:escapeToShellSafeString(argument)
end

function module:quoteEnvironmentVariable(argument)
	return self.shellLanguage:quoteEnvironmentVariable(argument)
end

function module:redirectStandardOutput(filePathOrFileDescriptor)
	return self.shellLanguage:redirectStandardOutput(filePathOrFileDescriptor)
end

function module:appendLines(...)
	local commandStrings = {...}
	for _, commandString in ipairs(commandStrings) do
		assert.parameterTypeIsString('commandString', commandString)
		
		tabelizedScriptBuffer:insert(self.shellLanguage:terminateShellCommandString(commandString))
	end
end

function module:appendCommandLineToScript(...)
	return self.shellLanguage:appendCommandLineToScript(self.tabelizedScriptBuffer, ...)
end

function module:relativeFolderPath(...)
	return self.shellLanguage:relativeFolderPath(...)
end

