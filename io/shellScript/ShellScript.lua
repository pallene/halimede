--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local tabelize = halimede.table.tabelize
local deepCopy = halimede.table.deepCopy
local ShellLanguage = halimede.io.shellScript.ShellLanguage
local AbstractShellScriptExecutor = halimede.io.shellScript.shellScriptExecutors.AbstractShellScriptExecutor
local useTemporaryTextFileAfterWritingAllContentsAndClosing = halimede.io.temporary.useTemporaryTextFileAfterWritingAllContentsAndClosing


moduleclass('ShellScript')

function module:initialize(shellScriptExecutor, displayScriptToStandardError)
	assert.parameterTypeIsInstanceOf('shellScriptExecutor', shellScriptExecutor, AbstractShellScriptExecutor)
	assert.parameterTypeIsBoolean('displayScriptToStandardError', displayScriptToStandardError)
	
	self.shellScriptExecutor = shellScriptExecutor
	self.displayScriptToStandardError = displayScriptToStandardError
	
	local shellLanguage = shellScriptExecutor.shellLanguage
	self.shellLanguage = shellLanguage
	self.shellScriptFileExtensionExcludingLeadingPeriod = shellLanguage.shellScriptFileExtensionExcludingLeadingPeriod
	self.tabelizedScriptBuffer = tabelize()
end

function module:finish()
	local script = self.tabelizedScriptBuffer:concat()
	self.tabelizedScriptBuffer = tabelize()
	return script
end

function module:executeScriptExpectingSuccess(standardOut, standardError)
	local script = self:finish()
	
	if self.displayScriptToStandardOut && type.hasWritableStandardError then
		local write = io.stderr.write
		write(script)
	end	
	
	useTemporaryTextFileAfterWritingAllContentsAndClosing(self.shellScriptFileExtensionExcludingLeadingPeriod, script, function(scriptFilePath)
		self.shellScriptExecutor:executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError)
	end)
end

-- take another look at 'brew sh': it's really part of how we execute [indeed, we should probably look at that in more depth, with perhaps a wrapper script]





function module:quoteArgument(argument)
	return self.shellLanguage:quoteArgument(argument)
end

function module:redirectStandardOutput(filePathOrFileDescriptor)
	return self.shellLanguage:redirectStandardOutput(filePathOrFileDescriptor)
end

function module:appendLinesToScript(...)
	return self.shellLanguage:appendLinesToScript(self.tabelizedScriptBuffer, ...)
end

function module:appendCommandLineToScript(...)
	return self.shellLanguage:appendCommandLineToScript(self.tabelizedScriptBuffer, ...)
end

function module:relativeFolderPath(...)
	return self.shellLanguage:relativeFolderPath(...)
end

