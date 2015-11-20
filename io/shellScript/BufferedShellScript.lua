--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local BufferedShellScript = moduleclass('BufferedShellScript')

local halimede = require('halimede')
local tabelize = require('halimede.table.tabelize').tabelize
local deepCopy = require('halimede.table.deepCopy').deepCopy
local ShellLanguage = require('halimede.io.shellScript.ShellLanguage')
local AbstractShellScriptExecutor = require('halimede.io.shellScript.shellScriptExecutors.AbstractShellScriptExecutor')
local toTemporaryFileAllContentsInTextModeAndUse = require('halimede.io.temporaryWrite').toTemporaryFileAllContentsInTextModeAndUse


function BufferedShellScript:initialize(shellScriptExecutor)
	assert.parameterTypeIsInstanceOf('shellScriptExecutor', shellScriptExecutor, AbstractShellScriptExecutor)
	
	self.shellScriptExecutor = shellScriptExecutor
	
	self.shellLanguage = shellScriptExecutor.shellLanguage
	self.tabelizedScriptBuffer = tabelize()
end

function BufferedShellScript:quoteArgument(argument)
	return self.shellLanguage:quoteArgument(argument)
end

function BufferedShellScript:redirectStandardOutput(filePathOrFileDescriptor)
	return self.shellLanguage:redirectStandardOutput(filePathOrFileDescriptor)
end

function BufferedShellScript:appendLinesToScript(...)
	self.shellLanguage:appendLinesToScript(self.tabelizedScriptBuffer, ...)
end

function BufferedShellScript:appendCommandLineToScript(...)
	self.shellLanguage:appendCommandLineToScript(self.tabelizedScriptBuffer, ...)
end

function BufferedShellScript:finish()
	local script = self.tabelizedScriptBuffer:concat(self.shellLanguage.newline)
	self.tabelizedScriptBuffer = tabelize()
	return script
end

function BufferedShellScript:executeScriptExpectingSuccess(standardOut, standardError)
	local script = self:finish()
	
	toTemporaryFileAllContentsInTextModeAndUse(script, self.shellLanguage.shellScriptFileExtensionExcludingLeadingPeriod, function(scriptFilePath)
		self.shellScriptExecutor:executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError)
	end)
end
