--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local tabelize = halimede.table.tabelize
local deepCopy = halimede.table.deepCopy
local ShellLanguage = halimede.io.shellScript.ShellLanguage
local AbstractShellScriptExecutor = halimede.io.shellScript.shellScriptExecutors.AbstractShellScriptExecutor
local useTemporaryTextFileAfterWritingAllContentsAndClosing = halimede.io.temporary.useTemporaryTextFileAfterWritingAllContentsAndClosing


moduleclass('BufferedShellScript')

function module:initialize(shellScriptExecutor)
	assert.parameterTypeIsInstanceOf('shellScriptExecutor', shellScriptExecutor, AbstractShellScriptExecutor)
	
	self.shellScriptExecutor = shellScriptExecutor
	
	self.shellLanguage = shellScriptExecutor.shellLanguage
	self.tabelizedScriptBuffer = tabelize()
end

function module:quoteArgument(argument)
	assert.parameterTypeIsString('argument', argument)
	
	return self.shellLanguage:quoteArgument(argument)
end

function module:redirectStandardOutput(filePathOrFileDescriptor)
	assert.parameterTypeIsNumberOrString('filePathOrFileDescriptor', filePathOrFileDescriptor)
	
	return self.shellLanguage:redirectStandardOutput(filePathOrFileDescriptor)
end

function module:appendLinesToScript(...)
	self.shellLanguage:appendLinesToScript(self.tabelizedScriptBuffer, ...)
end

function module:appendCommandLineToScript(...)
	self.shellLanguage:appendCommandLineToScript(self.tabelizedScriptBuffer, ...)
end

function module:finish()
	local script = self.tabelizedScriptBuffer:concat()
	self.tabelizedScriptBuffer = tabelize()
	return script
end

function module:executeScriptExpectingSuccess(standardOut, standardError)
	local script = self:finish()
	
	useTemporaryTextFileAfterWritingAllContentsAndClosing(self.shellLanguage.shellScriptFileExtensionExcludingLeadingPeriod, script, function(scriptFilePath)
		self.shellScriptExecutor:executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError)
	end)
end
